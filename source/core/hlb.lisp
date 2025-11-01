(defpackage #:core/hlb
  (:use #:cl)
  (:export #:calculate-hlb
           #:hlb->type
           #:surfactant-type
           #:*surfactant-db*
           #:surfactant-type
           #:calculate-blend-hlb
           #:print-hlb-result)
  (:documentation "HLB Calculator Logic."))
(in-package #:core/hlb)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Classes

#+(or)
(defclass surfactant ()
  ((id    :initarg :id :reader surfactant-id
          :initform (gensym "SURF%")
          :type symbol
          :documentation "ID of the surfactant")
   (name  :initarg :name :reader surfactant-name :type string
          :documentation "Name of the surfactant")
   (inci  :initarg :inci :reader surfactant-inci :type stringe
          :documentation "Chemical ingredient nomenclature designation")
   (type  :initarg :type :reader surfactant-type :initform :anionic
          :type (member :anionic :cationic :non-ionic :amphoteric)
          :documentation "Surfactant type")   
   (hlb   :initarg :hlb :reader surfactant-hlb :type real
          :documentation "HLB")
   (hld   :initarg :hld :reader surfactant-hld :type real
          :documentation "HLD"))
  (:documentation "Represents a single surfactant entry."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; HLB Calculator Core

(defun calculate-hlb (hydrophilic-weight lipophilic-weight)
  "Calculate HLB using: HLB = 20 * (hydrophilic mass / total mass)"
  (check-type hydrophilic-weight real)
  (check-type lipophilic-weight real)
  (let ((total (+ hydrophilic-weight lipophilic-weight)))
    (if (zerop total)
        0.0
        (* 20.0 (/ hydrophilic-weight total)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Surfactant Classification

(defun hlb->type (hlb)
  "Return surfactant application based on HLB value."
  (check-type hlb real)
  (cond
    ((< hlb 3)   "Antifoaming agent")
    ((< hlb 6)   "W/O emulsifier")
    ((< hlb 8)   "Wetting agent")
    ((< hlb 10)  "O/W emulsifier (weak)")
    ((< hlb 13)  "O/W emulsifier")
    ((< hlb 15)  "Detergent")
    ((< hlb 18)  "Solubilizer / Hydrotrope")
    (t           "Stabilizer / Dispersant")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Surfactant HLB Database

(defstruct surfactant
  "A surfactant data structure."
  (id (gensym "SURF%") :type symbol :read-only t)
  (name "" :type string)
  (hlb nil :type (or null real))
  (inci "" :type string)
  (class :anionic :type (member :anionic :cationic :non-ionic :amphoteric)))

(defparameter *surfactant-db*
  '((:span-80  . 4.3)   ; Sorbitan monooleate
    (:tween-20 . 16.7)  ; Polysorbate 20
    (:tween-80 . 15.0)  ; Polysorbate 80
    (:sls      . 40.0)  ; Sodium Lauryl Sulfate (capped at 20 in blends)
    (:scg      . 18.00) ; Sodium Cocoyl Glutamate
    (:brij-35  . 16.9))
  "Database of known surfactants and their HLB values.")

(defun surfactant-type (name)
  "Lookup HLB and type of a known surfactant."
  (let ((entry (assoc name *surfactant-db*)))
    (when entry
      (let ((hlb (cdr entry)))
        (values hlb (hlb->type hlb))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Blend Calculator (Weighted Average)

(defun calculate-blend-hlb (components)
  "Calculate HLB of a blend. COMPONENTS: ((mass1 surfactant1) ...)"
  (let ((total-mass 0.0)
        (weighted-hlb 0.0))
    (dolist (c components)
      (destructuring-bind (mass surf) c
        (multiple-value-bind (hlb found) (surfactant-type surf)
          (when found
            (incf total-mass mass)
            (incf weighted-hlb (* mass hlb))))))
    (if (zerop total-mass)
        0.0
        (/ weighted-hlb total-mass))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Pretty Printing

(defun print-hlb-result (hlb &optional stream)
  (format stream "HLB: ~,2F → ~A~%" hlb (hlb->type hlb)))
