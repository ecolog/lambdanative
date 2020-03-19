#|
LambdaNative - a cross-platform Scheme framework
Copyright (c) 2009-2014, University of British Columbia
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the
following conditions are met:

* Redistributions of source code must retain the above
copyright notice, this list of conditions and the following
disclaimer.

* Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials
provided with the distribution.

* Neither the name of the University of British Columbia nor
the names of its contributors may be used to endorse or
promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

;; time entry widget consisting of two vertical value pickers for hours and minutes

;; Valid hours and minutes, as strings to show 2 characters at all times
(define glgui:timepicker_hours `("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11"
                                "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23"))
;; Use same list for minutes and seconds (if used)
(define glgui:timepicker_minutes `("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" 
                                  "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" 
                                  "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" 
                                  "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" 
                                  "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" 
                                  "50" "51" "52" "53" "54" "55" "56" "57" "58" "59"))
(define glgui:timepicker_hours_ampm `("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"))

(define (glgui:timepicker-calculate g wgt widget hpicker mpicker spicker ampmbutton)
    ;; Build a date string from the hour and minute (and maybe second)
    (let* ((oldvalue (glgui-widget-get g widget 'value))
           (hourrange (glgui-widget-get g hpicker 'vallist))
           (oldhourindex (glgui:timepicker-get-hour hourrange oldvalue ampmbutton))
           (hourindex (fix (glgui-widget-get g hpicker 'value)))
           (hour (if (fx< hourindex (length hourrange)) (list-ref hourrange hourindex) (car hourrange)))
           (minuterange (glgui-widget-get g mpicker 'vallist))
           (minuteindex (fix (glgui-widget-get g mpicker 'value)))
           (minute (if (fx< minuteindex (length minuterange)) (list-ref minuterange minuteindex) (car minuterange)))
           (second (if spicker
                     (let ((secondrange (glgui-widget-get g spicker 'vallist))
                           (secondindex (fix (glgui-widget-get g spicker 'value))))
                       (if (fx< secondindex (length secondrange)) (list-ref secondrange secondindex) (car secondrange)))
                     "00"))
           (oldampm (glgui:timepicker-get-ampm oldvalue))
           ;; Update AM/PM when going from 11->12 or 12->11, or when AM/PM button pressed
           (newampm (if (or (and (fx= oldhourindex 10) (fx= hourindex 11)) (and (fx= oldhourindex 11) (fx= hourindex 10)) (eqv? wgt ampmbutton))
                      (if (string=? oldampm "AM") " PM" " AM")
                      (string-append " " oldampm))))
       ;; Get the time specified in the pickers as a string
       (let* ((timestr (string-append "1/1/1970 " hour ":" minute ":" second (if ampmbutton newampm "")))
              (newvalue (string->seconds timestr (string-append "%m/%d/%Y " (if ampmbutton "%I:%M:%S %p" "%H:%M:%S")))))
         ;; Set the current time
         (glgui-widget-set! g widget 'value newvalue))
    )
    ;; Then call the callback for this component - if there is one
    (let ((cb (glgui-widget-get g widget 'callback)))
       (if cb (cb g widget)))
)

(define (glgui:timepicker-callback widget hpicker mpicker spicker ampmbutton)
  ;; The wgt parameter in the lambda is the specific picker
  (lambda (g wgt . x)
    (glgui:timepicker-calculate g wgt widget hpicker mpicker spicker ampmbutton)
))

(define (glgui:timepicker-middle-callback widget hpicker mpicker spicker hinput minput sinput)
  (lambda (g wgt . x)
    (let ((hval (glgui-widget-get g hpicker 'value))
          (hvallist (glgui-widget-get g hpicker 'vallist))
          (mval (glgui-widget-get g mpicker 'value))
          (mvallist (glgui-widget-get g mpicker 'vallist))
          (ampm (glgui-widget-get g widget 'ampmbutton))
          (bg (glgui-widget-get g widget 'bg))
          (c1label (glgui-widget-get g widget 'c1label))
          (c2label (glgui-widget-get g widget 'c2label))
          (tc1label (glgui-widget-get g widget 'tc1label))
          (tc2label (glgui-widget-get g widget 'tc2label))
          (keypad (glgui-widget-get g widget 'keypad))
          (keypadcb (glgui-widget-get g widget 'keypadcb)))
      (glgui-widget-set! g tc1label 'hidden #f)
      (if tc2label
        (glgui-widget-set! g tc2label 'hidden #f))
      (if ampm
        (glgui-widget-set! g ampm 'hidden #t))
      (glgui-widget-set! g hinput 'label (list-ref hvallist (fix hval)))
      (glgui-widget-set! g minput 'label (list-ref mvallist (fix mval)))
      (if (and spicker sinput)
        (let ((sval (glgui-widget-get g spicker 'value))
              (svallist (glgui-widget-get g spicker 'vallist)))
          (glgui-widget-set! g sinput 'label (list-ref svallist (fix sval)))))
      (glgui-widget-set! g hinput 'focus #f)
      (glgui-widget-set! g minput 'focus #f)
      (glgui-widget-set! g hinput 'hidden #f)
      (glgui-widget-set! g minput 'hidden #f)
      (if sinput
        (begin
          (glgui-widget-set! g sinput 'focus #f)
          (glgui-widget-set! g sinput 'hidden #f)))
      (glgui-widget-set! g hpicker 'hidden #t)
      (glgui-widget-set! g mpicker 'hidden #t)
      (if spicker
        (glgui-widget-set! g spicker 'hidden #t))
      (glgui-widget-set! g c1label 'hidden #t)
      (if c2label
        (glgui-widget-set! g c2label 'hidden #t))
      (glgui-widget-set! g bg 'hidden #t)
      (glgui-widget-set! g (if (eqv? wgt hpicker) hinput (if (eqv? wgt mpicker) minput sinput)) 'focus #t)
      (glgui-widget-set! g keypad 'hidden #f)
      (if keypadcb (keypadcb g wgt))
    )
  )
)

(define (glgui:timepicker-input-callback widget hpicker mpicker spicker ampmbutton hinput minput sinput)
  ;; Convert single digit response ("X") to double digit ("0X")
  (lambda (g wgt . x)
    (let* ((hlabel0 (glgui-widget-get g hinput 'label))
           (hlabel (if (= (string-length hlabel0) 1) (string-append "0" hlabel0) hlabel0))
           (hvallist (glgui-widget-get g hpicker 'vallist))
           (mlabel0 (glgui-widget-get g minput 'label))
           (mlabel (if (= (string-length mlabel0) 1) (string-append "0" mlabel0) mlabel0))
           (mvallist (glgui-widget-get g mpicker 'vallist))
           (keypad (glgui-widget-get g widget 'keypad))
           (keypadcb (glgui-widget-get g widget 'keypadcb))
           (bg (glgui-widget-get g widget 'bg))
           (c1label (glgui-widget-get g widget 'c1label))
           (c2label (glgui-widget-get g widget 'c2label))
           (tc1label (glgui-widget-get g widget 'tc1label))
           (tc2label (glgui-widget-get g widget 'tc2label)))
      (if (list-pos hvallist hlabel)
          (glgui-widget-set! g hpicker 'value (list-pos hvallist hlabel)))
      (if (list-pos mvallist mlabel)
          (glgui-widget-set! g mpicker 'value (list-pos mvallist mlabel)))
      (if (and spicker sinput)
        (let* ((slabel0 (glgui-widget-get g sinput 'label))
               (slabel (if (= (string-length slabel0) 1) (string-append "0" slabel0) slabel0))
               (svallist (glgui-widget-get g spicker 'vallist)))
            (if (list-pos svallist slabel)
              (glgui-widget-set! g spicker 'value (list-pos svallist slabel)))))
      (glgui-widget-set! g hinput 'hidden #t)
      (glgui-widget-set! g minput 'hidden #t)
      (if sinput
        (glgui-widget-set! g sinput 'hidden #t))
      (glgui-widget-set! g tc1label 'hidden #t)
      (if tc2label
        (glgui-widget-set! g tc2label 'hidden #t))
      (glgui-widget-set! g keypad 'hidden #t)
      (glgui-widget-set! g hpicker 'hidden #f)
      (glgui-widget-set! g mpicker 'hidden #f)
      (if spicker
        (glgui-widget-set! g spicker 'hidden #f))
      (glgui-widget-set! g c1label 'hidden #f)
      (if c2label
        (glgui-widget-set! g c2label 'hidden #f))
      (if ampmbutton
          (glgui-widget-set! g ampmbutton 'hidden #f))
      (glgui-widget-set! g bg 'hidden #f)
      (if keypadcb (keypadcb g wgt))
    )
    (glgui:timepicker-calculate g wgt widget hpicker mpicker spicker ampmbutton)
  )
)

;; Limit length of hour, minute, second input to 2 chars
(define (glgui:timepicker-keypad-aftercharcb g wgt t x y)
  (let* ((label (glgui-widget-get g wgt 'label))
         (strlen (string-length label)))
    (if (> strlen 2)
      (glgui-widget-set! g wgt 'label (substring label 0 2))
    )
  )
)

(define (glgui:timepicker-get-hour range secs ampm)
  (let* ((hourstr (seconds->string secs (if ampm "%I" "%H")))
         (index (list-pos range hourstr)))
    (if index index 0))
)

(define (glgui:timepicker-get-minute range secs)
  (let* ((minutestr (seconds->string secs "%M"))
         (index (list-pos range minutestr)))
    (if index index 0))
)

(define (glgui:timepicker-get-second range secs)
  (let* ((secondstr (seconds->string secs "%S"))
         (index (list-pos range secondstr)))
    (if index index 0))
)

(define (glgui:timepicker-get-ampm secs)
  (seconds->string secs "%p")
)

;; When any parameters of the widget are updated, potentially update the individual pickers for hours and minutes
(define (glgui:timepicker-update g wgt id val)
  (let* ((hpicker (glgui-widget-get g wgt 'hourpicker))
         (mpicker (glgui-widget-get g wgt 'minutepicker))
         (spicker (glgui-widget-get g wgt 'secondpicker))
         (ampmbutton (glgui-widget-get g wgt 'ampmbutton))
         (bg (glgui-widget-get g wgt 'bg))
         (c1label (glgui-widget-get g wgt 'c1label))
         (c2label (glgui-widget-get g wgt 'c2label))
         (hinput (glgui-widget-get g wgt 'hinput))
         (minput (glgui-widget-get g wgt 'minput))
         (sinput (glgui-widget-get g wgt 'sinput))
         (tc1label (glgui-widget-get g wgt 'tc1label))
         (tc2label (glgui-widget-get g wgt 'tc2label))
         (keypad (glgui-widget-get g wgt 'keypad)))
    (cond 
      ;; Directly update all widgets for some parameters
      ((or (eqv? id 'hidden) (eqv? id 'modal))
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if ampmbutton (glgui-widget-set! g ampmbutton id val))
        (glgui-widget-set! g bg id val)
        (glgui-widget-set! g c1label id val)
        (if c2label
          (glgui-widget-set! g c2label id val)))
      ((eqv? id 'font)
        (glgui-widget-set! g hpicker 'fnt val)
        (glgui-widget-set! g mpicker 'fnt val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if ampmbutton (glgui-widget-set! g ampmbutton id val))
        (glgui-widget-set! g c1label id val)
        (if c2label
          (glgui-widget-set! g c2label id val))
        (glgui-widget-set! g hinput id val)
        (glgui-widget-set! g minput id val)
        (if sinput
          (glgui-widget-set! g sinput id val))
        (glgui-widget-set! g keypad 'fnt val))
      ((eqv? id 'y)
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if ampmbutton (let ((ampm-h (glgui-widget-get g wgt 'h)))
          (glgui-widget-set! g ampmbutton id (+ val (/ ampm-h 3)))))
        (glgui-widget-set! g bg id val)
        (glgui-widget-set! g c1label id val)
        (if c2label
          (glgui-widget-set! g c2label id val)))
      ((eqv? id 'h)
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if ampmbutton (let ((ampm-y (glgui-widget-get g wgt 'y)))
          (glgui-widget-set! g ampmbutton 'y (+ ampm-y (/ val 3)))
          (glgui-widget-set! g ampmbutton id (/ val 3))))
        (glgui-widget-set! g bg id val)
        (glgui-widget-set! g c1label id val)
        (if c2label
          (glgui-widget-set! g c2label id val))
        (glgui-widget-set! g hinput id (/ val 3))
        (glgui-widget-set! g minput id (/ val 3))
        (if sinput
          (glgui-widget-set! g sinput id (/ val 3)))
        (glgui-widget-set! g tc1label id (/ val 3))
        (if tc2label
          (glgui-widget-set! g tc2label id (/ val 3))))
      ((eqv? id 'colorvalue)
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if ampmbutton (glgui-widget-set! g ampmbutton 'color val))
        (glgui-widget-set! g c1label 'color val)
        (if c2label
          (glgui-widget-set! g c2label 'color val))
        (glgui-widget-set! g hinput 'color val)
        (glgui-widget-set! g minput 'color val)
        (if sinput
          (glgui-widget-set! g sinput 'color val))
        (glgui-widget-set! g tc1label 'color val)
        (if tc2label
          (glgui-widget-set! g tc2label 'color val)))
      ((eqv? id 'colorbg)
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (glgui-widget-set! g bg 'color (if val val (color-fade White 0.)))
        (glgui-widget-set! g c1label 'bgcolor val)
        (if c2label
          (glgui-widget-set! g c2label 'bgcolor val)))
     ;; Directly update the minute and hour pickers for some parameters
      ((or (eqv? id 'topdown) (eqv? id 'colorarrows) (eqv? id 'colorhighlight) (eqv? id 'scalearrows))
        (glgui-widget-set! g hpicker id val)
        (glgui-widget-set! g mpicker id val)
        (if spicker
          (glgui-widget-set! g spicker id val))
        (if (eqv? id 'colorhighlight)
          (begin
            (glgui-widget-set! g hinput 'bgcolor val)
            (glgui-widget-set! g minput 'bgcolor val)
            (if sinput
              (glgui-widget-set! g sinput 'bgcolor val))
            (glgui-widget-set! g tc1label 'bgcolor val)
            (if tc2label
              (glgui-widget-set! g tc2label 'bgcolor val)))))
      ;; Directly update the ampm button for some parameters
      ((and ampmbutton (eqv? id 'button-normal-color))
        (glgui-widget-set! g ampmbutton id (if val val (color-fade White 0.))))
      ;; Change in value - update pickers
      ((eqv? id 'value)
        (glgui-widget-set! g hpicker 'value (glgui:timepicker-get-hour (glgui-widget-get g hpicker 'vallist) val ampmbutton))
        (glgui-widget-set! g mpicker 'value (glgui:timepicker-get-minute (glgui-widget-get g mpicker 'vallist) val))
        (if spicker
          (glgui-widget-set! g spicker 'value (glgui:timepicker-get-second (glgui-widget-get g spicker 'vallist) val)))
        (if ampmbutton
          (let ((ampm-str (glgui:timepicker-get-ampm val)))
            (glgui-widget-set! g ampmbutton 'value (if (string=? ampm-str "AM") 0 1))
            (glgui-widget-set! g ampmbutton 'image (list ampm-str)))))
      ;; Update x or w
      ((or (eqv? id 'x) (eqv? id 'w))
        (let* ((w (glgui-widget-get g wgt 'w))
               (x (glgui-widget-get g wgt 'x))
               (div (+ 2 (if ampmbutton 1 0) (if spicker 1 0)))
               (dx (fix (/ (- w div) div)))
               (hdx (/ dx 2))
               (hw (/ (glgui-width-get) 2)))
          (glgui-widget-set! g hpicker 'x x)
          (glgui-widget-set! g hpicker 'w dx)
          (glgui-widget-set! g mpicker 'x (+ x dx))
          (glgui-widget-set! g mpicker 'w dx)
          (glgui-widget-set! g c1label 'x (- (+ x dx) 5))
          (if spicker
            (begin
              (glgui-widget-set! g spicker 'x (+ x (* dx 2)))
              (glgui-widget-set! g spicker 'w dx)
              (glgui-widget-set! g c2label 'x (- (+ x (* dx 2)) 5))))
          (glgui-widget-set! g hinput 'w dx)
          (glgui-widget-set! g minput 'w dx)
          (if sinput
            (begin
              (glgui-widget-set! g hinput 'x (- hw hdx dx 10))
              (glgui-widget-set! g tc1label 'x (- hw hdx 10))
              (glgui-widget-set! g minput 'x (- hw hdx))
              (glgui-widget-set! g tc2label 'x (+ hw hdx))
              (glgui-widget-set! g sinput 'x (+ hw hdx 10))
              (glgui-widget-set! g sinput 'w dx))
            (begin
              (glgui-widget-set! g hinput 'x (- hw dx 5))
              (glgui-widget-set! g tc1label 'x (- hw 5))
              (glgui-widget-set! g minput 'x (+ hw 5))))
          (if ampmbutton
            (begin
              (glgui-widget-set! g ampmbutton 'x (+ x (* dx (if spicker 3 2))))
              (glgui-widget-set! g ampmbutton 'w dx)))
          (glgui-widget-set! g bg 'x x)
          (glgui-widget-set! g bg 'w w)))
      ;; Update the limits
      ((or (eqv? id 'hourmax) (eqv? id 'hourmin))
         (let* ((max (glgui-widget-get g wgt 'hourmax))
                (min (glgui-widget-get g wgt 'hourmin))
                (wrapped (fx< max min))
                (lastindex (if wrapped (- 23 (- min max 1)) (- max min)))
                (newrange (if wrapped
                            (append (list-tail glgui:timepicker_hours min) (list-head glgui:timepicker_hours (+ max 1)))
                            (list-head (list-tail glgui:timepicker_hours min) (+ lastindex 1)))))
           (glgui-widget-set! g hpicker 'vallist newrange)
           (glgui-widget-set! g hpicker 'valmax lastindex)
           ;; Now reset value
           (glgui:timepicker-update g wgt 'value (glgui-widget-get g wgt 'value))))
      ;; Switch from 24hr to AM/PM and vice versa
      ((eqv? id 'ampm)
       (let* ((w (glgui-widget-get g wgt 'w))
              (x (glgui-widget-get g wgt 'x))
              (h (glgui-widget-get g wgt 'h))
              (y (glgui-widget-get g wgt 'y))
              (font (glgui-widget-get g wgt 'font))
              (div (+ 2 (if val 1 0) (if spicker 1 0)))
              (dx (fix (/ (- w div) div)))
              (hdx (/ dx 2))
              (hw (/ (glgui-width-get) 2))
              (value (glgui-widget-get g wgt 'value))
              (hourlist (if val glgui:timepicker_hours_ampm glgui:timepicker_hours))
              (hourupdated (glgui:timepicker-get-hour hourlist value val)))
         (glgui-widget-set! g hpicker 'vallist hourlist)
         (glgui-widget-set! g hpicker 'value hourupdated)
         (glgui-widget-set! g hpicker 'valmax (- (length hourlist) 1))
         (glgui-widget-set! g hpicker 'x x)
         (glgui-widget-set! g hpicker 'w dx)
         (glgui-widget-set! g mpicker 'x (+ x dx))
         (glgui-widget-set! g mpicker 'w dx)
         (glgui-widget-set! g c1label 'x (- (+ x dx) 5))
         (if spicker
           (begin
             (glgui-widget-set! g spicker 'x (+ x (* dx 2)))
             (glgui-widget-set! g spicker 'w dx)
             (glgui-widget-set! g c2label 'x (- (+ x (* dx 2)) 5))))
         (glgui-widget-set! g hinput 'w dx)
         (glgui-widget-set! g minput 'w dx)
         (if sinput
           (begin
             (glgui-widget-set! g hinput 'x (- hw hdx dx 10))
             (glgui-widget-set! g tc1label 'x (- hw hdx 10))
             (glgui-widget-set! g minput 'x (- hw hdx))
             (glgui-widget-set! g tc2label 'x (+ hw hdx))
             (glgui-widget-set! g sinput 'x (+ hw hdx 10))
             (glgui-widget-set! g sinput 'w dx))
           (begin
             (glgui-widget-set! g hinput 'x (- hw dx 5))
             (glgui-widget-set! g tc1label 'x (- hw 5))
             (glgui-widget-set! g minput 'x (+ hw 5))))
         (if (not val) (glgui-widget-delete g ampmbutton))
         (let ((ampmbutton (if val (glgui-button-string g (+ x (* dx (if spicker 3 2))) (+ y (/ h 3)) dx (/ h 3) "AM" font #f) #f)))
           (glgui-widget-set! g wgt 'ampmbutton ampmbutton)
           (if ampmbutton
             (begin
               (glgui-widget-set! g ampmbutton 'button-normal-color (glgui-widget-get g wgt 'button-normal-color))
               (glgui-widget-set! g ampmbutton 'color (glgui-widget-get g wgt 'colorvalue))
               (glgui-widget-set! g ampmbutton 'button-selected-color (glgui-widget-get g wgt 'colorhighlight))
               (glgui-widget-set! g ampmbutton 'solid-color #t)
               (glgui-widget-set! g ampmbutton 'callback (glgui:timepicker-callback wgt hpicker mpicker spicker ampmbutton))))
           (glgui-widget-set! g hpicker 'callback (glgui:timepicker-callback wgt hpicker mpicker spicker ampmbutton))
           (glgui-widget-set! g mpicker 'callback (glgui:timepicker-callback wgt hpicker mpicker spicker ampmbutton))
           (if spicker
             (glgui-widget-set! g spicker 'callback (glgui:timepicker-callback wgt hpicker mpicker spicker ampmbutton)))
           (glgui-widget-set! g hinput 'callback (glgui:timepicker-input-callback wgt hpicker mpicker spicker ampmbutton hinput minput sinput))
           (glgui-widget-set! g minput 'callback (glgui:timepicker-input-callback wgt hpicker mpicker spicker ampmbutton hinput minput sinput))
           (if sinput
             (glgui-widget-set! g sinput 'callback (glgui:timepicker-input-callback wgt hpicker mpicker spicker ampmbutton hinput minput sinput)))
           (glgui:timepicker-update g wgt 'value value))))
  ))
)

;; Create this time widget
(define (glgui-timepicker g x y w h colorarrows colorhighlight colorvalue colorbg font . seconds)
  (let* ((time ##now)
         (seconds? (and (list? seconds) (fx> (length seconds) 0) (car seconds)))
         (dx (fix (/ (- w 2) (if seconds? 3 2))))
         (hdx (/ dx 2))
         (hw (/ (glgui-width-get) 2))
         ;; Create the two vertical pickers for hours and minutes and the colon in between
         (bg (glgui-box g x y w h (if colorbg colorbg (color-fade White 0.))))
         (hpicker (glgui-verticalvaluepicker g x y dx h #f #f colorarrows colorhighlight colorvalue colorbg font glgui:timepicker_hours))
         (mpicker (glgui-verticalvaluepicker g (+ x dx) y dx h #f #f colorarrows colorhighlight colorvalue colorbg font glgui:timepicker_minutes))
         ;; Make seconds picker if using seconds. Cannot turn this option on and off later
         (spicker (if seconds?
                    (glgui-verticalvaluepicker g (+ x (* dx 2)) y dx h #f #f colorarrows colorhighlight colorvalue colorbg font glgui:timepicker_minutes)
                     #f))
         (c1label (glgui-label g (- (+ x dx) 5) y 10 h ":" font colorvalue colorbg))
         (c2label (if seconds?
                    (glgui-label g (- (+ x (* dx 2)) 5) y 10 h ":" font colorvalue colorbg)
                    #f))
         (keypad-h (/ (glgui-height-get) 2))
         (hinput (glgui-inputlabel g (- hw (if seconds? (+ hdx 5) 0) dx 5) (+ keypad-h 5) dx (/ h 3) "0" font colorvalue colorbg))
         (tc1label (glgui-label g (- hw (if seconds? (+ hdx 10) 5)) (+ keypad-h 5) 10 (/ h 3) ":" font colorvalue colorbg))
         (minput (glgui-inputlabel g (+ hw (if seconds? (- 0 hdx) 5)) (+ keypad-h 5) dx (/ h 3) "0" font colorvalue colorbg))
         (tc2label (if seconds?
                     (glgui-label g (+ hw hdx) (+ keypad-h 5) 10 (/ h 3) ":" font colorvalue colorbg)
                      #f))
         (sinput (if seconds?
                   (glgui-inputlabel g (+ hw hdx 10) (+ keypad-h 5) dx (/ h 3) "0" font colorvalue colorbg)
                   #f))
         (keypad (glgui-keypad g 0 0 (glgui-width-get) keypad-h font keypad:numeric))
         (widget (glgui-widget-add g
          'x x
          'y y
          'w w
          'h h
          'ampm #f
          'callback #f
          'update-handle glgui:timepicker-update
          'hidden #f
          'value time
          ;; Maximum and minimum hour selectable, can wrap around (ex. 20 and 6 for range 20:00-6:59)
          'hourmin 0
          'hourmax 23
          'colorarrows colorarrows
          'colorhighlight colorhighlight
          'colorvalue colorvalue
          'colorbg colorbg
          'button-normal-color (if colorbg colorbg (color-fade White 0.))
          'font font
          ;; Topdown can be set to true to reverse the order of times (down arrow to get to later times instead of up arrow)
          'topdown #f
          'scalearrows #f
          ;; The pickers that make up this widget
          'hourpicker hpicker
          'minutepicker mpicker
          'secondpicker spicker
          'ampmbutton #f
          'bg bg
          'c1label c1label
          'c2label c2label
          'hinput hinput
          'minput minput
          'sinput sinput
          'keypadcb #f
          'tc1label tc1label
          'tc2label tc2label
          'keypad keypad
          )))
    ;; The pickers can roll through from :23 or :59 over to :00
    (glgui-widget-set! g hpicker 'cycle #t)
    (glgui-widget-set! g mpicker 'cycle #t)
    ;; Hook into the callback of the pickers, inputs
    (glgui-widget-set! g hpicker 'callback (glgui:timepicker-callback widget hpicker mpicker spicker #f))
    (glgui-widget-set! g mpicker 'callback (glgui:timepicker-callback widget hpicker mpicker spicker #f))
    (glgui-widget-set! g hpicker 'callbackmid (glgui:timepicker-middle-callback widget hpicker mpicker spicker hinput minput sinput))
    (glgui-widget-set! g mpicker 'callbackmid (glgui:timepicker-middle-callback widget hpicker mpicker spicker hinput minput sinput))
    (glgui-widget-set! g hinput 'callback (glgui:timepicker-input-callback widget hpicker mpicker spicker #f hinput minput sinput))
    (glgui-widget-set! g minput 'callback (glgui:timepicker-input-callback widget hpicker mpicker spicker #f hinput minput sinput))
    (glgui-widget-set! g hinput 'aftercharcb glgui:timepicker-keypad-aftercharcb)
    (glgui-widget-set! g minput 'aftercharcb glgui:timepicker-keypad-aftercharcb)
    ;; Set topdown and values for the pickers
    (glgui:timepicker-update g widget 'topdown #f)
    (glgui:timepicker-update g widget 'value time)
    ;; Format and hide keypad, inputs
    (glgui-widget-set! g keypad 'hidden #t)
    (glgui-widget-set! g keypad 'rounded #f)
    (glgui-widget-set! g keypad 'bgcolor Black)
    (glgui-widget-set! g hinput 'hidden #t)
    (glgui-widget-set! g hinput 'align GUI_ALIGNCENTER)
    (glgui-widget-set! g minput 'hidden #t)
    (glgui-widget-set! g minput 'align GUI_ALIGNCENTER)
    (glgui-widget-set! g tc1label 'hidden #t)
    (glgui-widget-set! g tc1label 'align GUI_ALIGNCENTER)
    (if seconds?
      (begin
        (glgui-widget-set! g spicker 'cycle #t)
        (glgui-widget-set! g spicker 'callback (glgui:timepicker-callback widget hpicker mpicker spicker #f))
        (glgui-widget-set! g spicker 'callbackmid (glgui:timepicker-middle-callback widget hpicker mpicker spicker hinput minput sinput))
        (glgui-widget-set! g sinput 'aftercharcb glgui:timepicker-keypad-aftercharcb)
        (glgui-widget-set! g sinput 'callback (glgui:timepicker-input-callback widget hpicker mpicker spicker #f hinput minput sinput))
        (glgui-widget-set! g sinput 'hidden #t)
        (glgui-widget-set! g sinput 'align GUI_ALIGNCENTER)
        (glgui-widget-set! g tc2label 'hidden #t)
        (glgui-widget-set! g tc2label 'align GUI_ALIGNCENTER)))
    ;; Return the widget
    widget))
;; eof