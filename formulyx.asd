(defsystem "formulyx"
  :description "Formulation Chemistry Software Tool."
  :author "Erik P Almaraz"
  :license "Apache-2.0"
  :version (:read-file-form "version.sexp" :at (0 1))
  :depends-on 
  ("iterate"
   "bordeaux-threads"
   "lparallel"
   "alexandria"
   "cl-ppcre"
   "cl-dbi"
   ;; UI
   #+sbcl "cl-electron"
   ;; Local Systems (Libraries)
   "cl-chemexp")
  :components 
  ((:module "source"
    :components
    ((:module "core"
      :components
      ((:file "hlb")
       (:file "database")))
     (:module "ui"
      :components
      (#+sbcl (:file "electron")))
     (:file "formulyx"  :depends-on ("core" "ui")))))
  :in-order-to ((test-op (test-op "formulyx/tests")))
  :long-description "An advanced Formulation Chemistry Software tool.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Register Systems
;;; The function `register-system-packages' must be called to register packages
;;; used or provided by your system when the name of the system/file that 
;;; provides the package is not the same as the package name
;;; (converted to lower case).

(register-system-packages "iterate" '(:iter))
(register-system-packages "bordeaux-threads" '(:bt :bt2))
(register-system-packages "fiveam" '(:5am))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Secondary Systems

(defsystem "formulyx/tests"
  :depends-on ("formulyx" "fiveam")
  :components ((:module "tests"
                :components
                ((:file "suite"))))
  :perform (test-op (o c) 
                    (symbol-call :fiveam :run! :suite)))

(defsystem "formulyx/docs"
  :description "Documentation framework"
  :depends-on ("formulyx"
               "3bmd"
               "colorize"
               "print-licenses")
  :components
  ((:module "docs"
    :components
    ((:file "formulyx-docs")))))

(defsystem "formulyx/libraries"
  :description "Extra libraries to bring in if needed"
  :depends-on ("cl-chemexp"))

(defsystem "formulyx/executable"
  :description "Build executable"
  :depends-on ("formulyx")
  :build-operation "program-op"
  :build-pathname "build/formulyx"
  :entry-point "frmlx:main")
