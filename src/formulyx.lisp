(defpackage #:formulyx
  (:nicknames #:frmlx)
  (:use #:cl)
  (:import-from #:formulyx/core/utilities
                #:simple-pmap)
  (:import-from #:formulyx/ui/app
                #:start)
  (:export #:main
           #:doc-test)
  (:documentation "Formulyx"))

(in-package #:formulyx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Main Entry Point

#+nil
(uiop:register-image-restore-hook
 (lambda ()
   (format t "~&restore hook firing!~%")
   #+windows
   (let ((lib-dir (merge-pathnames "Programs/msys2/ucrt64/bin"
                                   (uiop:xdg-data-home))))
     (setf (uiop:getenv "PATH")
           (concatenate 'string
                        (namestring lib-dir)
                        ";" (uiop:getenv "PATH")))
     (pushnew lib-dir
              cffi:*foreign-library-directories*
              :test #'equal)))
 nil)

(defun main ()
  "Main entry point for application."
  (start))

(defun doc-test ()
  "Test to see if this is extracted into docs."
  t)
