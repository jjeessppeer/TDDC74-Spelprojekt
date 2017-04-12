#lang racket
(require racket/gui)
(provide sprite%)

(define sprite%
  (class object%
    (init-field x
                y
                [width 50.0]
                [height 50.0]
                [angle 0.0]
                [scaleX 1.0]
                [scaleY 1.0]
                [vx 0.0]
                [vy 0.0]
                [image (make-object bitmap% 10 10)])
    
    (define/public (get-x) x)
    (define/public (get-y) y)
    (define/public (get-vx) vx)
    (define/public (get-vy) vy)
    (define/public (get-height) height)
    (define/public (get-width) width)
    
    (define/public (set-x! xIn) (set! x xIn))
    (define/public (set-y! yIn) (set! y yIn))
    (define/public (set-vx! vxIn) (set! vx vxIn))
    (define/public (set-vy! vyIn) (set! vy vyIn))
    
    
    ;Sets the width/height and changes the scale so that the bitmap is drawn
    ;at the correct size.
    (define/public (set-width! wIn)
      (set! width wIn)
      (set! scaleX (/ wIn (send image get-width))))
    (define/public (set-height! hIn)
      (set! height hIn)
      (set! scaleY (/ hIn (send image get-height))))
    
    ;Sets the texture of a sprite to the specified image file and updates the scale
    (define/public (load-texture path)
      (send image load-file path 'png #f #t)
      (set-width! width)
      (set-height! height))
    
    ;Draws the sprite at the x,y coordinates
    (define/public (draw dc)
      (send dc rotate angle)
      (send dc scale scaleX scaleY)
      (send dc draw-bitmap image (/ x scaleX) (/ y scaleY))
      (send dc scale (/ 1 scaleX) (/ 1 scaleY))
      (send dc rotate (- angle)))
    
    ;Moves the sprite by its specified velocity in pixels/second
    ;dt should be the time since it last moved in seconds
    (define/public (move dt)
      (set! x (+ x (* vx dt)))
      (set! y (+ y (* vy dt))))
    
    
    (define/public (accelerate dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    
    
    
    
    
    
    
    
    
    
    
          
    
    
    (super-new)))