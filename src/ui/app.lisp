(defpackage #:formulyx/ui/app
  (:use #:cl)
  (:local-nicknames (#:og #:clog))
  (:import-from #:formulyx/core/scan
                #:generate-ternary-grid
                #:apply-to-grid
                #:gibbs-free-mixing
                #:export-ternary-grid
                #:default-export-path)
  (:import-from #:formulyx/ui/clog-widgets)
  (:export #:start)
  (:documentation "Main renderer application package."))

(in-package #:formulyx/ui/app)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; UI Widgets
(defclass widget ()
  ((element :initarg :element :accessor widget-element))
  (:documentation "Base Class for UI widgets."))

;;;
;;; Buttons
;;;
(defclass button-widget (widget)
  ((label    :initarg :label    :accessor button-label)
   (bg-color :initarg :bg-color :initform "#4c566a" :accessor button-bg-color)
   (fg-color :initarg :fg-color :initform "#d8dee9" :accessor button-fg-color))
  (:documentation "Button Widget Class."))

(defgeneric render (widget body)
  (:documentation "Render a widget into a CLOG body."))

(defmethod render ((btn button-widget) body)
  (let ((element (og:create-button body :content (button-label btn))))
    (style-button element (button-bg-color btn) (button-fg-color btn))
    (setf (widget-element btn) element)
    btn))

(defgeneric on-click (widget handler)
  (:documentation "Register a click handler on a widget."))

(defmethod on-click ((btn button-widget) handler)
  (og:set-on-click (widget-element btn) handler))

(defun style-button (btn bg-color fg-color)
  "Simple Button Styles."
  (setf (og:background-color btn) bg-color)
  (setf (og:color btn) fg-color)
  (setf (og:style btn "border") "none")
  (setf (og:style btn "padding") "6px 16px")
  (setf (og:style btn "margin-right") "8px")
  (setf (og:style btn "cursor") "pointer"))

;;;
;;; Input Fields
;;;
(defclass input-widget (widget)
  ((placeholder :initarg :placeholder :initform ""     :accessor input-placeholder)
   (width       :initarg :width       :initform "200px" :accessor input-width))
  (:documentation "Base input widget for text inputs."))

(defclass number-input-widget (input-widget)
  ((min :initarg :min :initform nil :accessor input-min)
   (max :initarg :max :initform nil :accessor input-max))
  (:documentation "Numeric input widget with optional min/max bounds."))

(defgeneric input-value (widget)
  (:documentation "Get the current value of an input widget."))

(defmethod render ((input input-widget) body)
  (let ((element (og:create-form-element body :input)))
    (style-input-field element (input-placeholder input) :width (input-width input))
    (setf (widget-element input) element)
    input))

(defmethod render ((input number-input-widget) body)
  (let ((element (og:create-form-element body :input)))
    (setf (og:attribute element "type") "number")
    (when (input-min input)
      (setf (og:attribute element "min") (write-to-string (input-min input))))
    (when (input-max input)
      (setf (og:attribute element "max") (write-to-string (input-max input))))
    (style-input-field element (input-placeholder input) :width (input-width input))
    (setf (widget-element input) element)
    input))

(defmethod input-value ((input input-widget))
  (og:value (widget-element input)))

(defun style-input-field (input placeholder &key (width "200px"))
  "Apply Nord-themed styles to an input element."
  (setf (og:attribute input "placeholder")  placeholder)
  (setf (og:style input "background-color") "#3b4252")
  (setf (og:style input "color")            "#d8dee9")
  (setf (og:style input "width")            width)
  (setf (og:style input "border")           "1px solid #4c566a")
  (setf (og:style input "padding")          "6px 10px")
  (setf (og:style input "margin-right")     "8px"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; UI Elements
(defun make-ternary-data (points)
  "Serialize (a b c value) points to Plotly scatterternary JSON string."
  (format nil (concatenate
               'string
               "a:[~{~4f~^,~}], b:[~{~4f~^,~}], c:[~{~4f~^,~}], "
               "marker:{color:[~{~4f~^,~}], "
               "colorscale:'Viridis', showscale:true, size:8}")
          (mapcar #'first points)
          (mapcar #'second points)
          (mapcar #'third points)
          (mapcar #'fourth points)))

(defun ternary-plot-layout (a-title b-title c-title)
  "Return Plotly layout JSON string for a Nord-themed ternary plot."
  (format nil "{
    paper_bgcolor: '#2e3440',
    font: { color: '#d8dee9' },
    ternary: {
      bgcolor: '#3b4252',
      aaxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' },
      baxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' },
      caxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' }
    }
  }" c-title a-title b-title))

(defun render-ternary-plot (body div fn &key (resolution 20)
                                             (a-title "A") 
                                             (b-title "B") 
                                             (c-title "C"))
  "Render a ternary plot into an existing div using fn over a generated grid."
  (let* ((grid (generate-ternary-grid resolution))
         (data (apply-to-grid grid fn)))
    (og:js-execute body
      (format nil (concatenate
                   'string
                   "Plotly.newPlot('~A', "
                   "[{ type: 'scatterternary', mode: 'markers', ~A }], "
                   "~A);")
              (og:html-id div)
              (make-ternary-data data)
              (ternary-plot-layout a-title b-title c-title)))))

(defun create-ternary-form (body fn &key (resolution 20)
                                         (a-title "A") 
                                         (b-title "B") 
                                         (c-title "C"))
  "Create resolution input, Generate Ternary button, Export CSV button, 
and initial plot."
  (let ((buffer (og:create-div body))
        (controls (og:create-div body))
        (echo (og:create-div body))
        (plot-div (og:create-div body)))
    (setf (og:style buffer "height") "20px")
    (setf (og:style echo "height") "20px")
    (setf (og:style controls "display") "flex")
    (setf (og:style controls "align-items") "center")
    (setf (og:style controls "gap") "8px")
    
    (let ((res-input  (og:create-form-element controls :input)))
      ;; Style resolution input field
      (setf (og:attribute res-input "type") "number")
      (setf (og:attribute res-input "min")  "2")
      (setf (og:attribute res-input "max")  "100")
      (style-input-field res-input (format nil "Resolution (default ~A)" resolution))

      ;; Plot Button
      (let ((gen-btn (make-instance 'button-widget
                                    :label "Plot Ternary"
                                    :bg-color "#8fbcbb" :fg-color "#2e3440")))
        (render gen-btn controls)
        (on-click
         gen-btn
         (lambda (obj)
           (declare (ignore obj))
           (let* ((raw (og:value res-input))
                  (res (or (and raw (> (length raw) 0)
                                (parse-integer raw :junk-allowed t))
                           resolution)))
             (render-ternary-plot body plot-div fn
                                  :resolution res
                                  :a-title a-title
                                  :b-title b-title
                                  :c-title c-title)))))

      ;; CSV Export Input Field, Button, and Status field
      (let ((path-input (og:create-form-element controls :input))
            (csv-btn (make-instance 'button-widget
                                    :label "Export to CSV"
                                    :bg-color "#b48ead" :fg-color "#2e3440"))
            (status (og:create-section echo :p :content "")))
        ;; Style filepath input
        (style-input-field path-input "File Name (e.g. grid.csv)" :width "200px")
        (render csv-btn controls)
        (on-click
         csv-btn
         (lambda (obj)
           (declare (ignore obj))
           (let* ((raw (og:value res-input))
                  (res (or (and raw (> (length raw) 0)
                                (parse-integer raw :junk-allowed t))
                           resolution))
                  (filepath (let ((p (og:value path-input)))
                              (if (and p (> (length p) 0))
                                  (merge-pathnames p (default-export-path)) 
                                  (merge-pathnames "ternary-grid.csv" (default-export-path))))))
             (handler-case
                 (progn
                   (export-ternary-grid res fn filepath)
                   (setf (og:text status) (format nil "Exported to ~A" filepath)))
               (error (e)
                 (setf (og:text status) (format nil "Export failed: ~A" e))))))))
    
      ;; Style plot div
      (setf (og:style plot-div "width")  "600px")
      (setf (og:style plot-div "height") "500px")
      (og:js-execute 
       body
       (format nil
               (concatenate
                'string
                "setTimeout(() => { "
                "Plotly.newPlot('~A', "
                "[{ type: 'scatterternary', mode: 'markers', ~A }], "
                "~A); }, 500);")
        (og:html-id plot-div)
        (make-ternary-data (apply-to-grid (generate-ternary-grid resolution) fn))
        (ternary-plot-layout a-title b-title c-title))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; UI Layout

(defun on-new-window (body)
  ;; Set favicon via head element
  (og:create-child (og:head-element (og:html-document body))
                   "<link rel=\"icon\" type=\"image/svg+xml\" href=\"/lisp-icon-sm.svg\">")

  (og:create-child (og:head-element (og:html-document body))
                   "<style>input[type=number]::-webkit-inner-spin-button,
                  input[type=number]::-webkit-outer-spin-button { -webkit-appearance: none; }
                  input[type=number] { -moz-appearance: textfield; }</style>")

  ;; Load Plotly for ternary plots
  (og:load-script (og:html-document body)
                  "https://cdn.plot.ly/plotly-3.4.0.min.js")

  (setf (og:background-color body) "#2e3440")
  (setf (og:color body) "#d8dee9")

  (let ((img (og:create-img body
                            :url-src  "/cl-logoraz.svg"
                            :alt-text "cl-logoraz")))
    (setf (og:width img) "100px"))

  ;; title is a setf-able accessor, not set-title
  (setf (og:title (og:html-document body)) "Formulyx")
  (og:create-section body :h1 :content "DOE Scan Grid Generator Tool")
  
  (let* ((words #("Enter mesh/resolution" "Plot to visualize" "or Export to CSV..."
                  "Color profile generated from  Gibbs Free Energy of Mixing."))
         (index 0)
         (display (og:create-section body :p :content (aref words index)))
         (btn (make-instance 'button-widget
                             :label "Help"
                             :bg-color "#ebcb8b" :fg-color "#2e3440")))
    (render btn body)
    (on-click
     btn
     (lambda (obj)
       (declare (ignore obj))
       (setf index (mod (1+ index) (length words)))
       (setf (og:text display) (aref words index)))))

  (let ((quit-btn (make-instance 'button-widget
                                 :label "Quit"
                                 :bg-color "#bf616a" :fg-color "#2e3440")))
    (render quit-btn body)
    (on-click
     quit-btn
     (lambda (obj)
       (declare (ignore obj))
       (og:create-section body :p :content "Closing Formulyx...")
       (sleep 1)
       (og:shutdown)
       (uiop:quit))))

    ;; Ternary form -- swap lambda for any f(a b c)
  (create-ternary-form body
                       #'gibbs-free-mixing
                       #+nil (lambda (a b c) (declare (ignore c)) (* a b))
                       :resolution 20
                       :a-title "Component A"
                       :b-title "Component B"
                       :c-title "Component C")

  ;; Quit app appropriately on tab/window close
  (og:set-html-on-close body "Formulyx Successfully Closed")
  (og:set-on-before-unload (og:window body)
                           (lambda (obj)
                             (declare (ignore obj))
                             (og:shutdown)
                             "")))

(defun start ()
  (og:initialize #'on-new-window
                 :static-root (asdf:system-relative-pathname :formulyx "assets/"))
  (og:open-browser))
