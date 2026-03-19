(defpackage #:formulyx/ui/clog-widgets
  (:use #:cl)
  (:local-nicknames (#:bt2 #:bordeaux-threads-2)
                    (#:og #:clog))
  ;; TODO remove this and move to app.list (controller)
  (:import-from #:formulyx/core/scan
                #:generate-ternary-grid
                #:apply-to-grid
                #+nil #:gibbs-free-mixing
                #:export-ternary-grid
                #:default-export-path)
  (:export #:render
           #:make-button
           #:on-click
           #:make-text-input
           #:make-number-input
           #:make-value-display
           #:make-ternary-plot
           #:make-ternary-panel)
  (:documentation "CLOS widget framework for CLOG (view)."))

(in-package #:formulyx/ui/clog-widgets)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Base UI Widgets
(defclass widget ()
  ((element :initarg :element :accessor widget-element))
  (:documentation "Base Class for UI widgets."))

;;;
;;; Interface (Generic Functions)
;;;
(defgeneric render (widget body)
  (:documentation "Render a widget into a CLOG body."))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Buttons
(defclass button-widget (widget)
  ((label    :initarg :label    :accessor button-label)
   (bg-color :initarg :bg-color :initform "#4c566a" :accessor button-bg-color)
   (fg-color :initarg :fg-color :initform "#d8dee9" :accessor button-fg-color))
  (:documentation "Button Widget Class."))

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
;;; Button Constructors
;;;
(defun make-button (label &key (bg-color "#4c566a") (fg-color "#d8dee9"))
  "Create a button widget."
  (make-instance 'button-widget
                 :label label :bg-color bg-color :fg-color fg-color))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Input Fields
(defclass input-widget (widget)
  ((placeholder :initarg :placeholder :initform "" :accessor input-placeholder)
   (width :initarg :width :initform "200px" :accessor input-width))
  (:documentation "Base input widget for text inputs."))

(defclass number-input-widget (input-widget)
  ((min :initarg :min :initform nil :accessor input-min)
   (max :initarg :max :initform nil :accessor input-max))
  (:documentation "Numeric input widget with optional min/max bounds."))

(defgeneric input-value (widget)
  (:documentation "Get the current value of an input widget."))

(defmethod render ((input input-widget) body)
  (let ((element (og:create-form-element body :input)))
    (style-input-field element 
                       (input-placeholder input) :width (input-width input))
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

;;;
;;; Display Box
;;;
(defclass value-display-widget (input-widget)
  ()
  (:documentation "Read-only text display widget."))

(defgeneric set-value (widget value)
  (:documentation "Set the displayed value of a widget."))

(defmethod set-value ((display value-display-widget) value)
  (setf (og:value (widget-element display)) value))

(defmethod render ((display value-display-widget) body)
  (call-next-method)
  (setf (og:attribute (widget-element display) "readonly") "true")
  (setf (og:attribute (widget-element display) "disabled") "true")
  display)

;;;
;;; Input/Display Field Constructors
;;;
(defun make-text-input (placeholder &key (width "200px"))
  "Create a text input widget."
  (make-instance 'input-widget
                 :placeholder placeholder :width width))

(defun make-number-input (placeholder &key (width "200px") min max)
  "Create a numeric input widget with optional bounds."
  (make-instance 'number-input-widget
                 :placeholder placeholder :width width :min min :max max))

(defun make-value-display (placeholder &key (width "200px"))
  "Create a read-only value display widget."
  (make-instance 'value-display-widget
                 :placeholder placeholder :width width))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Plots
(defclass plot-widget (widget)
  ((width  :initarg :width  :initform "600px" :accessor plot-width)
   (height :initarg :height :initform "500px" :accessor plot-height)
   (fn     :initarg :fn                       :accessor plot-fn))
  (:documentation "Base plot widget class."))

(defclass ternary-plot-widget (plot-widget)
  ((resolution :initarg :resolution :initform 20  :accessor plot-resolution)
   (a-title    :initarg :a-title    :initform "A" :accessor plot-a-title)
   (b-title    :initarg :b-title    :initform "B" :accessor plot-b-title)
   (c-title    :initarg :c-title    :initform "C" :accessor plot-c-title))
  (:documentation "Ternary plot widget class."))

(defgeneric plot-data (widget)
  (:documentation "Serialize plot widget data to a JSON string."))

(defgeneric plot-layout (widget)
  (:documentation "Serialize plot widget layout to a JSON string."))

(defgeneric update (widget body)
  (:documentation "Re-render/update a plot widget with current state."))

(defmethod plot-data ((plot ternary-plot-widget))
  (let* ((grid (generate-ternary-grid (plot-resolution plot)))
         (points (apply-to-grid grid (plot-fn plot))))
    (format nil (concatenate
                 'string
                 "a:[~{~4f~^,~}], b:[~{~4f~^,~}], c:[~{~4f~^,~}], "
                 "marker:{color:[~{~4f~^,~}], "
                 "colorscale:'Viridis', showscale:true, size:8}")
            (mapcar #'first points)
            (mapcar #'second points)
            (mapcar #'third points)
            (mapcar #'fourth points))))

(defmethod plot-layout ((plot ternary-plot-widget))
  (format nil "{
    paper_bgcolor: '#2e3440',
    font: { color: '#d8dee9' },
    ternary: {
      bgcolor: '#3b4252',
      aaxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' },
      baxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' },
      caxis: { title: { text: '~A' }, color: '#d8dee9', ticks: 'outside' }
    }
  }" (plot-c-title plot) (plot-a-title plot) (plot-b-title plot)))

(defmethod render ((plot ternary-plot-widget) body)
  (let ((div (og:create-div body)))
    (setf (og:style div "width")  (plot-width plot))
    (setf (og:style div "height") (plot-height plot))
    (setf (widget-element plot) div)
    (og:js-execute 
     body
     (format nil (concatenate
                  'string
                  "setTimeout(() => { Plotly.newPlot('~A', "
                  "[{ type: 'scatterternary', mode: 'markers', ~A }], "
                  "~A); }, 500);")
             (og:html-id div)
             (plot-data plot)
             (plot-layout plot)))
    plot))

(defmethod update ((plot ternary-plot-widget) body)
  (og:js-execute 
   body
   (format nil (concatenate
                'string
                "Plotly.newPlot('~A', "
                "[{ type: 'scatterternary', mode: 'markers', ~A }], "
                "~A);")
           (og:html-id (widget-element plot))
           (plot-data plot)
           (plot-layout plot)))
  plot)

;;;
;;; Plot Constructors
;;;

(defun make-ternary-plot (fn &key (resolution 20) (width "600px") (height "500px")
                                  (a-title "A") (b-title "B") (c-title "C"))
  "Create a ternary plot widget."
  (make-instance 'ternary-plot-widget
                 :fn fn :resolution resolution :width width :height height
                 :a-title a-title :b-title b-title :c-title c-title))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Forms
(defclass panel-widget (widget)
  ((buffer-height :initarg :buffer-height :initform "20px"
                  :accessor panel-buffer-height)
   (buffer        :initform nil            :accessor panel-buffer))
  (:documentation "Base panel widget class."))

(defmethod render ((panel panel-widget) body)
  (let ((buffer (og:create-div body)))
    (setf (og:style buffer "height") (panel-buffer-height panel))
    (setf (panel-buffer panel) buffer)
    panel))

(defclass ternary-panel-widget (panel-widget)
  ((fn         :initarg :fn                        :accessor panel-fn)
   (resolution :initarg :resolution :initform 20   :accessor panel-resolution)
   (a-title    :initarg :a-title    :initform "A"  :accessor panel-a-title)
   (b-title    :initarg :b-title    :initform "B"  :accessor panel-b-title)
   (c-title    :initarg :c-title    :initform "C"  :accessor panel-c-title)
   (submit-btn :initform nil                        :accessor panel-submit-btn)
   (export-btn :initform nil                        :accessor panel-export-btn)
   (echo       :initform nil                        :accessor panel-echo)
   (echo-height :initarg :echo-height :initform "20px" :accessor panel-echo-height))
  (:documentation "Ternary panel widget class."))

(defgeneric load-resources (widget body)
  (:documentation "Load external resources required by a panel widget."))

(defgeneric on-submit (widget handler)
  (:documentation "Register a submit/plot handler on a panel widget."))

(defgeneric on-export (widget handler)
  (:documentation "Register an export handler on a panel widget."))

(defmethod load-resources ((panel ternary-panel-widget) body)
  (og:load-script (og:html-document body)
                  "https://cdn.plot.ly/plotly-3.4.0.min.js")
  (og:create-child
   (og:head-element (og:html-document body))
   "<style>input[type=number]::-webkit-inner-spin-button,
    input[type=number]::-webkit-outer-spin-button { -webkit-appearance: none; }
    input[type=number] { -moz-appearance: textfield; }</style>"))

(defmethod on-submit ((panel ternary-panel-widget) handler)
  (on-click (panel-submit-btn panel) handler))

(defmethod on-export ((panel ternary-panel-widget) handler)
  (on-click (panel-export-btn panel) handler))

(defmethod render ((panel ternary-panel-widget) body)
  (call-next-method)
  (load-resources panel body)
  (let ((controls (og:create-div body)))
    (setf (og:style controls "display")     "flex")
    (setf (og:style controls "align-items") "center")
    (setf (og:style controls "gap")         "8px")
    (let ((gridpoints-output (make-value-display "Grid Points" :width "100px"))
          (res-input (make-number-input (format nil "Resolution (default ~A)"
                                                (panel-resolution panel))
                                        :min 2 :max 100))
          (plot (make-ternary-plot (panel-fn panel)
                                   :resolution (panel-resolution panel)
                                   :a-title    (panel-a-title panel)
                                   :b-title    (panel-b-title panel)
                                   :c-title    (panel-c-title panel))))
      (render gridpoints-output controls)
      (render res-input controls)
      (let ((submit-btn (make-button "Plot Ternary"
                                     :bg-color "#8fbcbb" :fg-color "#2e3440")))
        (render submit-btn controls)
        (setf (panel-submit-btn panel) submit-btn))
      (let ((path-input (make-text-input "File Name (e.g. grid.csv)"
                                         :width "200px"))
            (export-btn (make-button "Export to CSV"
                                     :bg-color "#b48ead" :fg-color "#2e3440")))
        (render path-input controls)
        (render export-btn controls)
        (setf (panel-export-btn panel) export-btn)
        (let* ((echo (og:create-div body))
               (status (og:create-section echo :p :content "")))
          (setf (og:style echo "height") (panel-echo-height panel))
          (setf (panel-echo panel) echo)
          (on-submit panel
                     (lambda (obj)
                       (declare (ignore obj))
                       (let* ((raw (input-value res-input))
                              (res (or (and raw (> (length raw) 0)
                                            (parse-integer raw :junk-allowed t))
                                       (panel-resolution panel))))
                         (setf (plot-resolution plot) res)
                         (update plot body)
                         (set-value gridpoints-output
                                    (if (and raw (> (length raw) 0))
                                        (format nil "~A pts"
                                                (length (generate-ternary-grid res)))
                                        "")))))
          (on-export panel
                     (lambda (obj)
                       (declare (ignore obj))
                       (let* ((raw (input-value res-input))
                              (res (or (and raw (> (length raw) 0)
                                            (parse-integer raw :junk-allowed t))
                                       (panel-resolution panel)))
                              (filepath
                                (let ((p (input-value path-input)))
                                  (if (and p (> (length p) 0))
                                      (merge-pathnames p (default-export-path))
                                      (merge-pathnames "ternary-grid.csv"
                                                       (default-export-path))))))
                         (handler-case
                             (progn
                               (export-ternary-grid res (panel-fn panel) filepath)
                               (setf (og:text status)
                                     (format nil "Exported to ~A" filepath)))
                           (error (e)
                             (setf (og:text status)
                                   (format nil "Export failed: ~A" e))))))))
        (render plot body)))))

;;;
;;; Form Constructors
;;;
(defun make-ternary-panel (fn &key (resolution 20)
                                   (a-title "A") (b-title "B") (c-title "C")
                                   (buffer-height "20px") (echo-height "20px"))
  "Create a ternary panel widget."
  (make-instance 'ternary-panel-widget
                 :fn fn :resolution resolution
                 :a-title a-title :b-title b-title :c-title c-title
                 :buffer-height buffer-height :echo-height echo-height))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Pages
;;;

