(defsystem "formulyx"
  :description "Formulation Chemistry Software Tool."
  :author "Erik P Almaraz <erikalmaraz@fastmail.com>"
  :license "Apache-2.0"
  :version (:read-file-form "version.sexp" :at (0 1))
  :depends-on ("bordeaux-threads"
               "closer-mop"
               "cl-ppcre"
               "mito"
               #+sbcl "cl-gtk4"
               #+sbcl "cl-gobject-introspection-wrapper" ; List for visibility
               #+sbcl "cl-gtk4.adw"
               ;; Local Systems (aka libraries)
               )
  :components ;; Map of System
  ((:module "source"
    :components
    ((:module "utils" ;; Establish first our toolbox
      :components
      ((:file "syntax")))
     ;; Build out the core of aoforce
     (:module "core"
      :depends-on ("utils")
      :components
      ((:file "database")))
     ;; UI/X Frontends
     (:module "frontends"
      :components
      (#+sbcl (:file "adw-gtk4")))     
     ;; Finally scaffold formulyx
     (:file "formulyx"  :depends-on ("utils" "core" "frontends")))))
  :in-order-to ((test-op (test-op "formulyx/tests")))
  :long-description "An advanced Formulation Chemistry Software tool.")

;;; =============================================================================
;;; Register Systems
;;; =============================================================================
;; The function `register-system-packages' must be called to register packages
;; used or provided by your system when the name of the system/file that 
;; provides the package is not the same as the package name
;; (converted to lower case).
(register-system-packages "bordeaux-threads" '(:bt :bt2 :bordeaux-threads-2))
(register-system-packages "closer-mop" '(:c2mop :c2cl :c2cl-user))
(register-system-packages "fiveam" '(:5am))

;;; =============================================================================
;;; Secondary Systems
;;; =============================================================================
(defsystem "formulyx/tests"
  :description "Unit tests"
  :depends-on ("formulyx" "fiveam")
  :components
  ((:module "tests"
    :components
    ((:file "suite"))))
  :perform (test-op (o c)
                    (symbol-call :fiveam :run! :suite)))

(defsystem "formulyx/docs"
  :description "Documentation framework"
  :depends-on ("formulyx" "3bmd" "print-licenses")
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
  :build-pathname "formulyx-preexe"
  :entry-point "formulyx:main")
