(defpackage #:formulyx
  (:nicknames #:frmlx)
  (:use #:cl
        #:ui/electron)
  (:local-nicknames (#:it #:iterate))
  ;; External API
  (:export #:electron)
  ;; Play
  (:export #:simple-test
           #:simple-test2)
  (:documentation "Formulyx"))

(in-package #:formulyx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Entry Point

(defun electron ()
  "Main entry point for electron ui."
  (start-app))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Play 

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
