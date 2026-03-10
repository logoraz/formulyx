(defsystem "formulyx-system"
  :description "ASDF build extensions for Formulyx"
  :depends-on ("asdf" (:feature :windows "cffi"))
  :components ((:file "formulyx-system")))