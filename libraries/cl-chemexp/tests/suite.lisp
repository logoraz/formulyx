(defpackage #:tests/suite
  (:use #:cl
        #:5am
        #:utils/syntax
        #:cl-chemexp)
  (:export )
  (:documentation "Base Test Suite"))
(in-package #:tests/suite)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Define the test suite

(def-suite :suite :description "cl-chemexp test suite")
(in-suite :suite)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Example

#+nil
(test concat-test
  (is (string= "1 2" (concat "1 " "2"))))


