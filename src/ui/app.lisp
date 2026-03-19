(defpackage #:formulyx/ui/app
  (:use #:cl)
  (:local-nicknames (#:bt2 #:bordeaux-threads-2)
                    (#:og #:clog))
  (:import-from #:formulyx/core/scan
                #+nil #:generate-ternary-grid
                #+nil #:apply-to-grid
                #:gibbs-free-mixing
                #+nil #:export-ternary-grid
                #+nil #:default-export-path)
  (:import-from #:formulyx/ui/clog-widgets
                #:render
                #:make-button
                #:on-click
                #:make-text-input
                #:make-number-input
                #:make-value-display
                #:make-ternary-plot
                #:make-ternary-panel)
  (:export #:start)
  (:documentation "Main UI controller/renderer application package."))

(in-package #:formulyx/ui/app)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Main Window

(defun on-new-window (body)
  ;; Set favicon via head element
  (og:create-child 
   (og:head-element (og:html-document body))
   "<link rel=\"icon\" type=\"image/svg+xml\" href=\"/lisp-icon-sm.svg\">")

  (setf (og:background-color body) "#2e3440")
  (setf (og:color body) "#d8dee9")

  (let ((img (og:create-img body
                            :url-src  "/cl-logoraz.svg"
                            :alt-text "cl-logoraz")))
    (setf (og:width img) "100px"))

  ;; title is a setf-able accessor, not set-title
  (setf (og:title (og:html-document body)) "Formulyx")
  (og:create-section body :h1 :content "DOE Scan Grid Generator Tool")
  
  (let* ((words #("Enter mesh/resolution" "Plot to visualize" "or Export to CSV..."
                  "Color profile generated from  Gibbs Free Energy of Mixing."))
         (index 0)
         (display (og:create-section body :p :content (aref words index)))
         (btn (make-button "Help" :bg-color "#ebcb8b" :fg-color "#2e3440")))
    (render btn body)
    (on-click
     btn
     (lambda (obj)
       (declare (ignore obj))
       (setf index (mod (1+ index) (length words)))
       (setf (og:text display) (aref words index)))))

  (let ((quit-btn (make-button "Quit" :bg-color "#bf616a" :fg-color "#2e3440")))
    (render quit-btn body)
    (on-click
     quit-btn
     (lambda (obj)
       (declare (ignore obj))
       (og:create-section body :p :content "Closing Formulyx...")
       (sleep 1)
       (og:shutdown)
       (uiop:quit))))

  (let ((panel (make-ternary-panel #'gibbs-free-mixing
                                   :resolution 20
                                   :a-title    "Component A"
                                   :b-title    "Component B"
                                   :c-title    "Component C")))
    (render panel body))
  
  ;; Quit app appropriately on tab/window close
  (og:set-html-on-close body "Formulyx Successfully Closed")
  (og:set-on-before-unload (og:window body)
                           (lambda (obj)
                             (declare (ignore obj))
                             (og:shutdown)
                             "")))

(defun find-assets-root ()
  "Locate the root directory containing the assets/ folder.
Checks if assets/ exists relative to the runtime executable path via
UIOP:ARGV0, falling back to the current working directory for development
workflows where the binary is not present."
  (let* ((argv0 (uiop:argv0))
         (runtime-dir (when argv0
                        (uiop:pathname-directory-pathname
                         (parse-namestring argv0))))
         (runtime-assets (when runtime-dir
                           (merge-pathnames "assets/" runtime-dir))))
    (if (and runtime-assets (probe-file runtime-assets))
        runtime-dir
        (uiop:getcwd))))

(defun start ()
  (og:initialize
   #'on-new-window
   :static-root (merge-pathnames "assets/" (find-assets-root)))
  (og:open-browser)
  (let ((server-thread (find "clack-handler-hunchentoot" (bt2:all-threads)
                             :key #'bt2:thread-name
                             :test #'string=)))
    (when server-thread
      (handler-case
          (bt2:join-thread server-thread)
        (bt2:abnormal-exit () nil)))))