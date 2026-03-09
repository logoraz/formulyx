(defpackage #:formulyx
  (:nicknames #:frmlx)
  (:use #:cl)
  (:import-from #:formulyx/core/utilities
                #:simple-pmap)
  (:import-from #:formulyx/core/surfactant
                #:surfactant)
  (:import-from #:formulyx/ui/app
                #:start)
  (:export #:start
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
