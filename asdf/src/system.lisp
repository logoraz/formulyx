(defpackage #:frmlx-asdf-system/system
  (:use #:cl #:asdf #:uiop)
  (:export #:frmlx-system
           #:frmlx-exec-system)
  (:documentation "ASDF extension system for Formulyx."))

(in-package #:frmlx-asdf-system/system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Register Systems
(register-system-packages "bordeaux-threads" '(:bt :bt2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Custom System Classes

(defclass frmlx-system (system) ()
  (:documentation "Base system class for Formulyx."))

(defclass frmlx-exec-system (system) ()
  (:documentation "System class for Formulyx executable build."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Configure ocicl & Windows CFFI path for build

#+windows
(defmethod perform :before ((o load-op) (c frmlx-system))
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

#+windows
(defmethod perform ((o load-op) (c frmlx-exec-system))
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

#+windows
(defmethod perform :before ((o program-op) (c frmlx-exec-system))
  (loop for lib in (cffi:list-foreign-libraries :loaded-only t)
        do (cffi:close-foreign-library lib)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Enable SBCL core compression for executables

#+sb-core-compression
(defmethod perform ((o image-op) (c frmlx-exec-system))
  (uiop:dump-image (output-file o c) :executable t :compression t))
