(defpackage :tests/suite
  (:use :cl
        :5am
        :utils/syntax
        :formulyx)
  (:export )
  (:documentation "Base Test Suite"))
(in-package :tests/suite)


;;; =============================================================================
;;; Define the test suite
;;; =============================================================================
(def-suite :suite :description "Formulyx test suite")
(in-suite :suite)

;;; =============================================================================
;;; Let's first define the "easy" tests
;;; =============================================================================
;; (test concat-test
      ;; (is (string= "1 2" (concat "1 " "2"))))
