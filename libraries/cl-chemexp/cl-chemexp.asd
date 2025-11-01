(defsystem "cl-chemexp"
  :description "Chemical Expressions in Common Lisp"
  :author "Erik P Almaraz <erikalmaraz@fastmail.com"
  :license "Apache-2.0"
  :version (:read-file-form "version.sexp" :at (0 1))
  :depends-on
  ("iterate"
   "bordeaux-threads"
   "lparallel"
   "cl-ppcre"
   "local-time")
  :components
  ((:module "source"
    :components
    ( (:file "core"))))
  :in-order-to ((test-op (test-op "cl-chemexp/tests")))
  :long-description "
Tools to build Chemical Expressions in Common Lisp as S-expressions.
A WIP...
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Register Systems

;; The function `register-system-packages' must be called to register packages
;; used or provided by your system when the name of the system/file that 
;; provides the package is not the same as the package name
;; (converted to lower case).
(register-system-packages "iterate" '(:iter))
(register-system-packages "bordeaux-threads" '(:bt :bt2))
(register-system-packages "fiveam" '(:5am))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Secondary Systems

(defsystem "cl-chemexp/tests"
  :description "Unit tests"
  :depends-on ("cl-chemexp" "fiveam")
  :components
  ((:module "tests"
    :components
    ((:file "suite"))))
  :perform (test-op (o c)
                    (symbol-call :fiveam :run! :suite)))

(defsystem "cl-chemexp/docs"
  :description "Documentation framework"
  :depends-on ("cl-chemexp" "3bmd" "print-licenses")
  :components
  ((:module "docs"
    :components
    ((:file "cl-chemexp-docs")))))
