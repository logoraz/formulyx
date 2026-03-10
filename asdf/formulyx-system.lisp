(defpackage #:formulyx/asdf
  (:use #:cl #:asdf #:uiop)
  (:export #:formulyx-system
           #:formulyx-exec-system)
  (:documentation "ASDF extension system for Formulyx."))

(in-package #:formulyx/asdf)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Custom System Classes

(defclass formulyx-system (system) ()
  (:documentation "Base system class for Formulyx."))

(defclass formulyx-exec-system (system) ()
  (:documentation "System class for Formulyx executable build."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Register Systems

(register-system-packages "bordeaux-threads" '(:bt :bt2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Configure ocicl & Windows CFFI path for build

(defmethod perform :before ((o load-op) (c formulyx-system))
  #-ocicl
  (ignore-errors
    (let ((ocicl-runtime (uiop:xdg-data-home #P"ocicl/ocicl-runtime.lisp")))
      (when (probe-file ocicl-runtime)
        (load ocicl-runtime)))
    (asdf:initialize-source-registry
     (list :source-registry
           (list :tree (uiop:getcwd))
           :inherit-configuration)))
  #+windows
  (let ((lib-dir (merge-pathnames "Programs/msys2/ucrt64/bin"
                                  (uiop:xdg-data-home))))
    (setf (uiop:getenv "PATH")
          (concatenate 'string
                       (namestring lib-dir)
                       ";" (uiop:getenv "PATH")))
    (pushnew lib-dir
             cffi:*foreign-library-directories*
             :test #'equal)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Register image restore hook for Windows runtime library path

(defmethod perform ((o load-op) (c formulyx-exec-system))
  #+windows
  (uiop:register-image-restore-hook
   (lambda ()
     (let ((lib-dir (merge-pathnames "Programs/msys2/ucrt64/bin"
                                     (uiop:xdg-data-home))))
       (setf (uiop:getenv "PATH")
             (concatenate 'string
                          (namestring lib-dir)
                          ";" (uiop:getenv "PATH")))
       (pushnew lib-dir
                cffi:*foreign-library-directories*
                :test #'equal)))
   nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Close foreign libraries before saving image on Windows

(defmethod perform :before ((o program-op) (c formulyx-exec-system))
  #+windows
  (loop for lib in (cffi:list-foreign-libraries :loaded-only t)
        do (cffi:close-foreign-library lib)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Enable SBCL core compression for executables

#+sb-core-compression
(defmethod perform ((o image-op) (c formulyx-exec-system))
  (uiop:dump-image (output-file o c) :executable t :compression t))
