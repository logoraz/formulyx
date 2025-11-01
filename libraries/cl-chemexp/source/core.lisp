(defpackage :cl-chemexp/core
  (:use :cl)
  (:import-from :cl-ppcre
                :regex-replace)
  (:import-from :local-time
                :now)
  (:export #:test-fn)
  (:documentation "Molecular Expressions for Common Lisp."))

(in-package :cl-chemexp/core)

;;; Notes:
;;;
;;; WIP - Goal to create a tool set to build Chemical Expressions that transcribe
;;;       ChemML etc.
;;;

(defun test-fn ())
