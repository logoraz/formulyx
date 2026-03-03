(defpackage #:formulyx
  (:nicknames #:frmlx)
  (:use #:cl)
  (:import-from #:formulyx/core/utilities
                #:simple-pmap
                #:t-ex
                #:loop-ex)
  (:import-from #:formulyx/core/surfactant
                #:surfactant)
  (:import-from #:formulyx/ui/app
                #:start)
  (:export #:start
           #:loop-ex
           #:t-ex
           #:simple-pmap
           #:doc-test)
  (:documentation "Formulyx"))

(in-package #:formulyx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Main Entry Point

(defun doc-test ()
  "Test to see if this is extracted into docs."
  t)
