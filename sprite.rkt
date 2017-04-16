#lang racket
(require racket/gui)
(provide sprite%)

(define sprite%
  (class object%
    (init-field [x 0]
                [y 0]
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
    (define/public (get-center-x) (+ x (/ width 2)))
    (define/public (get-center-y) (+ y (/ height 2)))
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
    

      (define/public (copy-position! otherSprite)
        (set! x (send otherSprite get-x))
        (set! y (send otherSprite get-y)))

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
      (move-x dt)
      (move-y dt))
    (define/public (move-x dt)
      (set! x (+ x (* vx dt))))
    (define/public (move-y dt)
      (set! y (+ y (* vy dt))))
    
    (define/public (move-by vxIn vyIn dt)
      (set! x (+ x (* vxIn dt)))
      (set! y (+ y (* vyIn dt))))
    
    
    (define/public (acc-x dvx dt)
      (set! vx (+ vx (* dvx dt))))
    (define/public (acc-y dvy dt)
      (set! vy (+ vy (* dvy dt))))
    
    
    
    
    
    
    
    
    
    
    
    
          
    
    
    (super-new)))