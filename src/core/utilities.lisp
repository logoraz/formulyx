(defpackage #:formulyx/core/utilities
  (:use #:cl)
  (:local-nicknames (#:t #:transducers))
  (:export #:simple-pmap
           #:t-ex
           #:loop-ex
           #:gray
           #:wlog)
  (:documentation "Core utilities"))

(in-package #:formulyx/core/utilities)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Logging Utilities

;;; Logging
(defun bold-red (text)
  "Highlight some text in red."
  (format nil "~c[31;1m~a~c[0m" #\escape text #\escape))

(defun bold-cyan (text)
  "Highlight some text in cyan."
  (format nil "~c[96;1m~a~c[0m" #\escape text #\escape))

(defun bold-blue (text)
  "Highlight some text in bold blue."
  (format nil "~c[94;1m~a~c[0m" #\escape text #\escape))

(defun bold (text)
  "Just enbolden some text without colouring it."
  (format nil "~c[1m~a~c[0m" #\escape text #\escape))

(defun gray (text)
  "Highlight some text in gray."
  (format nil "~c[90m~a~c[0m" #\escape text #\escape))

(defun wlog (text &rest rest)
  (format t "~a " (bold-blue "[formulyx]"))
  (apply #'format t (gray text) rest)
  (format t "~%"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Examples

;; Simple parallel map with bordeaux-threads
(defun simple-pmap (function list)
  "Simple parallel map with bordeaux-thyreds"
  (let* ((threads
           (mapcar
            (lambda (item)
              (bt:make-thread
               (lambda () (funcall function item))))
            list))
         (results (mapcar #'bt:join-thread threads)))
    results))

(defun loop-ex (&optional (end 1000000))
  "Composable example with loop."
  (loop :for i :from 0 :to end :by 2
        :when (evenp i)
        :counting i :into count
        :summing (* i i) :into total
        :until (= count 10)
        :finally (return total)))

(defun t-ex ()
  "With cl-transducers - composable pipeline, no intermediates."
  (t:transduce
   (t:comp (t:filter #'evenp)
           (t:map (lambda (x) (* x x)))
           (t:take 10))
   #'+
   (t:ints 0)))

;; Scratch Notes
#+nil (consp nil) ;; NIL
#+nil (listp nil) ;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; TBD
