(defpackage #:formulyx/core/surfactant
  (:use #:cl)
  (:export #:surfactant)
  (:documentation "Surfactant Logic."))

(in-package #:formulyx/core/surfactant)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Classes

(defclass surfactant ()
  ((id    :initarg :id :reader surfactant-id
          :initform (gensym "SURF%")
          :type symbol
          :documentation "ID of the surfactant")
   (name  :initarg :name :reader surfactant-name :type string
          :documentation "Name of the surfactant")
   (inci  :initarg :inci :reader surfactant-inci :type string
          :documentation "Chemical ingredient nomenclature designation")
   (type  :initarg :type :reader surfactant-type :initform :anionic
          :type (member :anionic :cationic :amphoteric :non-ionic)
          :documentation "Surfactant type")
   (ph    :initarg :ph :reader surfactant-ph 
          :type (member real string)
          :documentation "pH")
   (hlb   :initarg :hlb :reader surfactant-hlb :type real
          :documentation "HLB")
   (hld   :initarg :hld :reader surfactant-hld :type real
          :documentation "HLD"))
  (:documentation "Represents a single surfactant entry."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; TODO

