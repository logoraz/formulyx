(defpackage #:formulyx/docs
  (:use #:cl
        #:formulyx)
  (:local-nicknames (#:md #:3bmd)
                    (#:clz #:colorize))
  (:export #:build-docs)
  (:documentation "Documentation system for formulyx"))

(in-package #:formulyx/docs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Ref: https://github.com/rabbibotton/clog/ --> source/clog-docs.lisp
;;; Build out further:

(defun render-md-file (input output)
  "Render MD file from INPUT and write normalized Markdown to OUTPUT."
  (with-open-file (in input)
    (with-open-file (out output
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
      (md:parse-and-print-to-stream in out))))

(defun generate-api-md (output-file &key (packages '(:formulyx)))
  "Generate an API reference in Markdown by extracting docstrings
from the given PACKAGES and writing them to OUTPUT-FILE.

PACKAGES should be a list of designators acceptable to FIND-PACKAGE.
Only exported symbols whose home package is that package are documented."
  (with-open-file (out output-file
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format out "# API Reference~%~%")

    (dolist (pkg packages)
      (let ((package (find-package pkg)))
        (when package
          (format out "## Package ~A~%~%" (package-name package))

          (do-external-symbols (sym package)
            ;; Only document symbols that PACKAGE actually exports
            (when (eq (symbol-package sym) package)
              (let ((fdoc (documentation sym 'function))
                    (vdoc (documentation sym 'variable))
                    (tdoc (documentation sym 'type))
                    (cdoc (documentation sym 'class)))
                (when fdoc
                  (format out "### `~A` (function)~%~A~%~%" sym fdoc))
                (when vdoc
                  (format out "### `~A` (variable)~%~A~%~%" sym vdoc))
                (when tdoc
                  (format out "### `~A` (type)~%~A~%~%" sym tdoc))
                (when cdoc
                  (format out "### `~A` (class)~%~A~%~%" sym cdoc))))))))))


(defun build-docs (&key keep)
  "Documentation builder for Formulyx.
If KEEP is true, retain individual section .html files.
Otherwise, delete them after building manual.html."
  (let* ((root   (asdf:system-source-directory :formulyx/docs))
         (manual (merge-pathnames "docs/manual/" root))
         (outdir (merge-pathnames "out/" manual))
         (sections '("intro.md" "usage.md" "api.md" "internals.md")))

    ;; Generate api.md before rendering
    (generate-api-md (merge-pathnames "api.md" manual)
                     :packages '(:formulyx))

    ;; Ensure output directory exists
    (ensure-directories-exist outdir)

    ;; Render each section individually
    (dolist (f sections)
      (let* ((input  (merge-pathnames f manual))
             (output (merge-pathnames
                      (concatenate 'string
                                   (pathname-name f)
                                   ".html")
                      outdir)))
        (render-md-file input output)))

    ;; Build combined manual.html
    (let ((combined (merge-pathnames "manual.html" outdir)))
      (with-open-file (out combined
                           :direction :output
                           :if-exists :supersede
                           :if-does-not-exist :create)
        (dolist (f sections)
          (let ((tmp (merge-pathnames
                      (concatenate 'string
                                   (pathname-name f)
                                   ".html")
                      outdir)))
            (with-open-file (in tmp)
              (loop for line = (read-line in nil nil)
                    while line do
                      (write-line line out)))
            (write-line "" out)))))

    ;; Delete individual section files unless KEEP is true
    (unless keep
      (dolist (f sections)
        (let ((tmp (merge-pathnames
                    (concatenate 'string
                                 (pathname-name f)
                                 ".html")
                    outdir)))
          (when (probe-file tmp)
            (delete-file tmp)))))

    (format t "Documentation built successfully.~%")))
