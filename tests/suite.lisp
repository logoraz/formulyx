(defpackage #:tests/suite
  (:nicknames #:suite)
  (:use #:cl #:5am)
  (:import-from #:core/hlb
                #:calculate-hlb
                #:hlb->type
                #:calculate-blend-hlb
                #:*surfactant-db*)
  (:documentation "Main test suite."))
(in-package #:tests/suite)

;; Define the test suite
(def-suite :suite :description "HLB test suite")
(in-suite :suite)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Core Tests

(test hlb-calculation
      (is (= 20.0 (calculate-hlb 100 0)))
      (is (= 0.0  (calculate-hlb 0 100)))
      (is (= 10.0 (calculate-hlb 50 50)))
      (is (= 14.0 (calculate-hlb 70 30)))
      (is (= 0.0 (calculate-hlb 0 0)) "Zero total mass returns 0"))

(test surfactant-classification
      (is (string= "Antifoaming agent" (hlb->type 2.0)))
      (is (string= "W/O emulsifier"     (hlb->type 5.0)))
      (is (string= "Wetting agent"      (hlb->type 7.5)))
      (is (string= "O/W emulsifier"     (hlb->type 11.0)))
      (is (string= "Detergent"          (hlb->type 14.0)))
      (is (string= "Solubilizer / Hydrotrope" (hlb->type 16.0)))
      (is (string= "Stabilizer / Dispersant"   (hlb->type 19.0))))

(test blend-calculator
      (let ((blend '((60 :tween-80) (40 :span-80))))
        (is (< 10.7 (calculate-blend-hlb blend) 10.8))))
