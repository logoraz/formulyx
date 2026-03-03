(defpackage #:formulyx/suite
  (:use #:cl)
  (:local-nicknames (#:prct #:parachute))
  (:import-from #:formulyx/core/hlb)
  (:documentation "Main test suite."))

(in-package #:formulyx/suite)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Core Tests

(prct:define-test formula-parsing
    (prct:is = 12 (molecular-weight "C"))
  (prct:is = 18 (molecular-weight "H2O")))

(prct:define-test utils
    (is equal "H2O" (normalize-formula "h2o")))
