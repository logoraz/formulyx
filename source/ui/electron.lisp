(defpackage #:ui/electron
  (:use #:cl)
  (:import-from #:alexandria #:assoc-value)
  (:local-nicknames (#:elec #:electron))
  (:export #:start-app)
  (:documentation "Example Electron UI using Nyxt's cl-electron."))
(in-package #:ui/electron)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Define Interface

(setf elec:*interface* (make-instance 'elec:interface))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Example Involved Electron UI

(defclass main-view (elec:view)
  ((url :initform nil))
  (:documentation "Main View Class"))

(defclass modeline (elec:view) 
  ()
  (:documentation "Modeline Empty  Class"))

(defclass prompt (elec:view)
  ()
  (:documentation "Prompt Empty Class"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Methods

(defmethod initialize-instance :after ((main-view main-view) &key window)
  (elec:add-bounded-view window
                         main-view
                         :window-bounds-alist-var bounds
                         :x 0
                         :y 0
                         :width (assoc-value bounds :width)
                         :height (- (assoc-value bounds :height) 30))
  (elec:add-listener (elec:web-contents main-view) :did-finish-load
                     (lambda (web-contents)
                       (setf (url main-view) (elec:get-url web-contents))))
  (elec:load-url main-view "https://github.com/logoraz/formulyx")
  (print (elec:execute-javascript-synchronous (elec:web-contents main-view)
                                              "1 + 1")))

(defmethod initialize-instance :after ((modeline modeline) &key window)
  (elec:add-bounded-view window
                         modeline
                         :window-bounds-alist-var bounds
                         :x 0
                         :y (- (assoc-value bounds :height) 30)
                         :width (assoc-value bounds :width)
                         :height 30)
  (elec:handle-callback (make-instance 'elec:protocol :scheme-name "lisp")
                        (lambda (url)
                          (declare (ignorable url))
                          "Caution: Made with secret alien technology"))
  (elec:set-background-color modeline "gray")
  (elec:load-url modeline "lisp:hello"))

(defmethod initialize-instance :after ((prompt prompt) &key window)
  (elec:add-bounded-view window
                         prompt
                         :window-bounds-alist-var bounds
                         :x 0
                         :y (floor (* (- (assoc-value bounds :height) 30) 2/3))
                         :width (assoc-value bounds :width)
                         :height (ceiling (/ (- (assoc-value bounds :height) 30) 3)))
  (elec:set-background-color prompt "lightskyblue")
  (elec:load-url prompt "about:blank"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Define Application

(defun start-app ()
  (elec:launch)
  
  (let* ((win (make-instance 'elec:window))
         (view (make-instance 'main-view :window win)))
    
    (elec:add-listener view :context-menu
                       (lambda (object params)
                         (declare (ignore object))
                         (print params)
                         "[{label: 'Custom Action',
                                click: () => {
                                  console.log('Custom action clicked');}},
                               {type: 'separator'},]"))
    
    (make-instance 'modeline :window win)
    #+nil (make-instance 'prompt :window win)
    win))
