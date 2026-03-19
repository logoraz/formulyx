(defpackage #:formulyx/core/utilities
  (:use #:cl)
  (:local-nicknames (#:bt2 #:bordeaux-threads-2))
  (:export #:simple-pmap
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

;; Scratch Notes
#+nil (consp nil) ;; NIL
#+nil (listp nil) ;; NIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; TBD
