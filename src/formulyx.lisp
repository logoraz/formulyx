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

(defun main ()
  "Main entry point for application."
  (start))

(defun doc-test ()
  "Test to see if this is extracted into docs."
  t)
