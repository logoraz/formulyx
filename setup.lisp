;;; setup.lisp — run with: sbcl --load setup.lisp
;;;
;;; Prerequisites:
;;; - ocicl: https://github.com/ocicl/ocicl
;;;   After installing, run: ocicl setup >> ~/.sbclrc
;;;
;;; On Windows (MSYS2/UCRT64):
;;;   ln -s libsqlite3-0.dll libsqlite3.dll
;;;   ln -s sqlite3-0.dll sqlite3.dll
;;;   Ensure ucrt64/bin is on PATH and in cffi:*foreign-library-directories*
;;;   (ocicl setup and the above should be in your ~/.sbclrc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Ensure ocicl is setup before building the executable
#-ocicl
(ignore-errors
  (let ((ocicl-runtime (uiop:xdg-data-home #P"ocicl/ocicl-runtime.lisp")))
    (when (probe-file ocicl-runtime)
      (load ocicl-runtime)))
  (asdf:initialize-source-registry
   (list :source-registry
         (list :tree (uiop:getcwd))
         :inherit-configuration)))

;;; Builder - copies distribution resources to build/
(defun copy-file (src dst)
  (uiop:copy-file src dst))

(defun ensure-build-dirs ()
  (let ((root (uiop:getcwd)))
    (uiop:ensure-all-directories-exist
     (list (merge-pathnames "build/assets/" root)
           (merge-pathnames "build/docs/"   root)
           (merge-pathnames "build/lib/"    root)))))

(defun copy-assets ()
  (let* ((root   (uiop:getcwd))
         (src    (merge-pathnames "assets/" root))
         (dst    (merge-pathnames "build/assets/" root)))
    (dolist (file (uiop:directory-files src))
      (copy-file file (merge-pathnames (file-namestring file) dst)))))

(asdf:load-system :formulyx)

;;; Close all foreign libraries before saving the image so SBCL does not
;;; try to reload them from a hardcoded path on startup
#+windows
(loop for lib in (cffi:list-foreign-libraries :loaded-only t)
      do (cffi:close-foreign-library lib))

(asdf:make :formulyx/exec)
(uiop:quit)

