(defpackage #:formulyx/ui/app
  (:use #:cl)
  (:local-nicknames (#:bt #:bordeaux-threads)
                    (#:og #:clog))
  (:import-from #:formulyx/core/utilities
                #:wlog)
  (:export #:start)
  (:documentation "Main renderer application package."))

(in-package #:formulyx/ui/app)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; UI Development with CLOG

(defun style-button (btn bg-color fg-color)
  "Simple Button Styles."
  (setf (og:background-color btn) bg-color)
  (setf (og:color btn) fg-color)
  (setf (og:style btn "border") "none")
  (setf (og:style btn "padding") "6px 16px")
  (setf (og:style btn "margin-right") "8px")
  (setf (og:style btn "cursor") "pointer"))

(defun on-new-window (body)
  ;; Set favicon via head element
  (og:create-child (og:head-element (og:html-document body))
                   "<link rel=\"icon\" type=\"image/svg+xml\" href=\"/lisp-icon-sm.svg\">")
  
  (setf (og:background-color body) "#2e3440")
  (setf (og:color body) "#d8dee9")
  
  (let ((img (og:create-img body
                            :url-src  "/cl-logoraz.svg"
                            :alt-text "cl-logoraz")))
    (setf (og:width img) "200px"))
  
  ;; title is a setf-able accessor, not set-title
  (setf (og:title (og:html-document body)) "Formulyx")
  (og:create-section body :h1 :content "Welcome to Formulyx!")
  
  (let* ((words #("" "In the beginning there was darkness..." "And God said..." "Let There be Light." "And there was Light!"))
         (index 0)
         (display (og:create-section body :p :content (aref words index)))
         (btn (og:create-button body :content "Click")))
    (style-button btn "#8fbcbb" "#2e3440")
    (og:set-on-click
     btn
     (lambda (obj)
       (declare (ignore obj))
       (setf index (mod (1+ index) (length words)))
       (setf (og:text display) (aref words index)))))

  (let ((quit-btn (og:create-button body :content "Quit")))
    (style-button quit-btn "#bf616a" "#2e3440")
    (og:set-on-click 
     quit-btn
     (lambda (obj)
       (declare (ignore obj))
       (og:create-section body :p :content "Closing Formulyx...")
       (sleep 1)
       (og:shutdown)
       (uiop:quit)))))

(defun start ()
  (og:initialize #'on-new-window
                 :static-root (asdf:system-relative-pathname :formulyx "assets/"))
  (og:open-browser))

