(defpackage #:cl-chemexp/core
  (:nicknames #:chemexp)
  (:use #:cl)
  (:local-nicknames (#:it #:iterate))
  (:export #:simple-test
           #:simple-test2)
  (:documentation "Chemical/Molecular Expressions for Common Lisp."))
(in-package #:cl-chemexp/core)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Notes

;;; WIP - Goal to create a tool set to build Chemical Expressions that transcribe
;;;       ChemML etc.

(defun simple-test (&optional (n 11))
  "Simple function for testing."
  (loop :for i :from 0 :below n
        :collect (list (format nil "list ~A" i)
                       (/ i n))))

(defun simple-test2 (&optional (n 11))
  "Simple function for testing."
  (it:iter (it:for i from 0 below n)
           (it:collect (list (format nil "list ~A" i)
                             (/ i n)))))
