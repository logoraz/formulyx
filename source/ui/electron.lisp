(defpackage #:ui/electron
  (:use #:cl)
  (:import-from #:nclasses #:define-class)
  (:import-from #:alexandria #:assoc-value)
  (:local-nicknames (#:e #:electron))
    (:export #:start-app)
  (:documentation "Example Electron UI"))

(in-package #:ui/electron)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Define Interface

(setf e:*interface* (make-instance 'e:interface))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Example Simple Electron UI

#+nil
(defun start-app ()
  (e:launch)
  (let ((win (make-instance 'e:window)))
    (e:load-url win "https://github.com/logoraz/formulyx")
    ;; Allow typing any character except "e".
    (e:add-listener win :before-input-event
                    (lambda (win input) (declare (ignore win))
                      (print input)
                      (if (string-equal "e" (assoc-value input :key)) t nil)))
    win))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Example Involved Electron UI

(define-class main-view (e:view)
  ((url nil)))

(defmethod initialize-instance :after ((main-view main-view) &key window)
  (e:add-bounded-view window
                      main-view
                      :window-bounds-alist-var bounds
                      :x 0
                      :y 0
                      :width (assoc-value bounds :width)
                      :height (- (assoc-value bounds :height) 30))
  (e:add-listener (e:web-contents main-view) :did-finish-load
                  (lambda (web-contents)
                    (setf (url main-view) (e:get-url web-contents))))
  (e:load-url main-view "https://github.com/logoraz/formulyx")
  (print (e:execute-javascript-synchronous (e:web-contents main-view)
                                           "1 + 1")))

(define-class modeline (e:view) ())

(defmethod initialize-instance :after ((modeline modeline) &key window)
  (e:add-bounded-view window
                      modeline
                      :window-bounds-alist-var bounds
                      :x 0
                      :y (- (assoc-value bounds :height) 30)
                      :width (assoc-value bounds :width)
                      :height 30)
  (e:handle-callback (make-instance 'e:protocol :scheme-name "lisp")
                     (lambda (url)
                       (declare (ignorable url))
                       "Caution: Made with secret alien technology"))
  (e:set-background-color modeline "gray")
  (e:load-url modeline "lisp:hello"))

(define-class prompt (e:view) ())

(defmethod initialize-instance :after ((prompt prompt) &key window)
  (e:add-bounded-view window
                      prompt
                      :window-bounds-alist-var bounds
                      :x 0
                      :y (floor (* (- (assoc-value bounds :height) 30) 2/3))
                      :width (assoc-value bounds :width)
                      :height (ceiling (/ (- (assoc-value bounds :height) 30) 3)))
  (e:set-background-color prompt "lightskyblue")
  (e:load-url prompt "about:blank"))

(defun start-app ()
  (e:launch)
  
  (let* ((win (make-instance 'e:window))
         (view (make-instance 'main-view :window win)))
    
    #+nil (make-instance 'main-view :window win)
    (electron:add-listener view :context-menu
                           (lambda (object params)
                             (declare (ignore object))
                             (print params)
                             "[{label: 'Custom Action',
                                click: () => {
                                  console.log('Custom action clicked');}},
                               {type: 'separator'},]"))
    
    (make-instance 'modeline :window win)
    (make-instance 'prompt :window win)
    win))