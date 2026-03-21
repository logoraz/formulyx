(defpackage #:formulyx/core/scan
  (:use #:cl)
  (:local-nicknames (#:csv #:cl-csv))
  (:export #:generate-ternary-grid
           #:apply-to-grid
           #:gibbs-free-mixing
           #:default-export-path
           #:export-ternary-grid)
  (:documentation "DOE Scan Grid Generation."))

(in-package #:formulyx/core/scan)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Ternary Scan Grid
(defun generate-ternary-grid (resolution)
  "Generate a unit ternary grid with given resolution (e.g. 10 = 0.1 step).
   Returns a list of (a b c) points where a + b + c = 1.0."
  (let ((step (/ 1.0 resolution))
        (points '()))
    (loop :for i :from 0 :to resolution
          :do (loop :for j :from 0 :to (- resolution i)
                    :do (let* ((a (* i step))
                               (b (* j step))
                               (c (- 1.0 a b)))
                          (push (list a b c) points))))
    (nreverse points)))

(defun apply-to-grid (grid fn)
  "Apply fn to each (a b c) point, returns (a b c value) list."
  (mapcar (lambda (p)
            (list (first p) (second p) (third p)
                  (funcall fn (first p) (second p) (third p))))
          grid))

(defun gibbs-free-mixing (a b c)
  "Ideal Gibbs free energy of mixing for a ternary system.
   Returns R*T * sum(xi * ln(xi)) where xi are the mole fractions.
   A small epsilon guards against log(0) at pure component vertices."
  (let ((epsilon 1.0e-10))
    (* (+ (* a (log (max a epsilon)))
          (* b (log (max b epsilon)))
          (* c (log (max c epsilon)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Export to CSV

(defun default-export-path ()
  "Return the default CSV export directory, creating it if necessary."
  (let ((dir (merge-pathnames "formulyx/tmp/"
                              (uiop:xdg-cache-home))))
    (ensure-directories-exist dir)
    dir))

(defun export-ternary-grid (resolution fn filepath)
  "Export a ternary grid with applied fn to a CSV file.
Ensures the filepath has a .csv extension, appending it if necessary."
  (let* ((filepath (if (string-equal (pathname-type filepath) "csv")
                       filepath
                       (make-pathname :type "csv" :defaults filepath)))
         (grid (generate-ternary-grid resolution))
         (data (apply-to-grid grid fn)))
    (with-open-file (stream filepath
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (csv:write-csv (cons '("A" "B" "C" "Value")
                           (mapcar (lambda (p)
                                     (list (first p) (second p)
                                           (third p) (fourth p)))
                                   data))
                     :stream stream))
    filepath))