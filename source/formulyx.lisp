(defpackage #:formulyx
  (:nicknames #:frmlx)
  (:use #:cl
        #+sbcl #:ui/electron)
  (:import-from #:chemexp
                #:simple-test
                #:simple-test2)
  (:local-nicknames (#:it #:iterate))
  ;; External API
  (:export #:electron)
  ;; Test - TODO remove
  (:export #:simple-test
           #:simple-test2)
  (:documentation "Formulyx"))
(in-package #:formulyx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Entry Point

#+sbcl
(defun electron ()
  "Main entry point for electron ui."
  (start-app))

