(defpackage :formulyx
  (:nicknames :fmlx)
  (:use :cl :asdf :uiop
        :gtk4
        :adwex)
  (:export #:simple-test
           #:test-utils
           #:main)
  (:documentation "Main package of formulyx"))
(in-package :formulyx)


;;; =============================================================================
;;; Tests
;;; =============================================================================
(defun simple-test (&optional (n 11))
  "Simple function for testing."
  (loop :for i :from 0 :below n
        :collect (list (format nil "list ~A" i)
                       (/ i n))))

;;; =============================================================================
;;; Entry Point
;;; =============================================================================
(defun main ()
  (unless (adw:initialized-p)
    (adw:init))
  (simple-repl))

#+nil
(defun main ()
  "Main entry point for the executable."
  (format t "Hello from Common Lisp! Arguments: ~A~%" 'no-args)
  #+or
  (progn
    #+clisp (ext:exit)
    #+(and ecl clasp) (ext:quit)
    #+ccl (ccl:quit)
    #+sbcl (sb-ext:quit))
  (uiop:quit))
