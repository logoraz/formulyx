(defpackage #:formulyx/ui/clog-widgets
  (:use #:cl)
  (:local-nicknames (#:bt #:bordeaux-threads)
                    (#:og #:clog))
  (:import-from #:formulyx/core/scan
                #:generate-ternary-grid
                #:apply-to-grid
                #:gibbs-free-mixing
                #:export-ternary-grid
                #:default-export-path)
  (:export #:start)
  (:documentation "CLOS widget framework for CLOG."))

(in-package #:formulyx/ui/clog-widgets)
