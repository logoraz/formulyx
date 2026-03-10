(defsystem "formulyx"
  :description "Formulation Chemistry Software Tool."
  :author "Erik P Almaraz"
  :license "AGPL-3.0-only"
  :version (:read-file-form "version.sexp" :at (0 1))
  :class "formulyx/asdf:formulyx-system"
  :defsystem-depends-on ("formulyx-system")
  :depends-on ("bordeaux-threads" "transducers" "transducers/jzon"
               "esrap" "cl-csv" "mito"
               "clog")
  :components
  ((:module "src"
    :components
    ((:module "core"
      :components
      ((:file "utilities")
       (:file "chexp")
       (:file "surfactant")
       (:file "scan")))
     (:module "ui"
      :depends-on ("core")
      :components
      ((:file "clog-widgets")
       (:file "app" :depends-on ("clog-widgets"))))
     (:file "formulyx"  :depends-on ("core" "ui")))))
  :in-order-to ((test-op (test-op "formulyx/tests")))
  :long-description "An advanced Formulation Chemistry Software tool.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Secondary Systems

(defsystem "formulyx/tests"
  :depends-on ("formulyx" "parachute")
  :components ((:module "tests"
                :components
                ((:file "suite"))))
  :perform (test-op (o c)
                    (symbol-call :parachute
                                 :test 'formulyx/suite)))

(defsystem "formulyx/docs"
  :description "Documentation builder for Formulyx."
  :depends-on ("formulyx"
               "3bmd"
               "3bmd-ext-code-blocks"
               "colorize"
               "print-licenses")
  :components
  ((:module "docs"
    :components
    ((:file "builder"))))
  :perform (build-op (o c)
                     (symbol-call 'formulyx/docs 'build-docs))
  :long-description "Documentation builder for Formulyx.

Run Build operation via:

  (asdf:make :formulyx/docs)

or alternatively,

  (asdf:operate 'asdf:build-op :formulyx/docs)")

(defsystem "formulyx/contrib"
  :description "Extra libraries to bring in if needed"
  :depends-on ("formulyx"))

(defsystem "formulyx/exec"
  :description "Build Executable"
  :class "formulyx/asdf:formulyx-exec-system"
  :depends-on ("formulyx")
  :build-operation "program-op"
  :build-pathname "build/formulyx"
  :entry-point "formulyx:main"
  :long-description "Build Formulyx Executable.

Build operation via:

  (asdf:make :formulyx/exec)")
