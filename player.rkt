#lang racket
(require racket/gui
         "sprite.rkt")
(provide player%)

(define player%
  (class sprite%
    (super-new)
    (init-field 
      [onGround #f]
      [gravityAcc 500]
      [sideAcc 500]
      [windowWidth 100]
      [windowHeight 100])
                
    (inherit-field 
      x y
      width height
      vx vy
      image)
    (inherit 
      acc-x acc-y
      set-vx!)
    
    (define/override (draw dc)
      (send dc draw-bitmap image x y)
      (send dc draw-bitmap image (+ x windowWidth) y)
      (send dc draw-bitmap image (- x windowWidth) y))
    
    (define/public (apply-gravity deltaT)
      (acc-y gravityAcc deltaT))
    
    (define/public (apply-friction deltaT)
      (set-vx! (* vx (expt 0.3 deltaT))))
    
    (define/public (side-accelerate LD RD deltaT)
      (when (xor LD RD)
        (let ([direction (if LD -1 1)])
          (acc-x (* direction sideAcc) deltaT))
        ))
          
          
    
    (define/public (platform-collission? platform deltaT)
      (or (pt-col-extra? platform deltaT 0)
          (pt-col-extra? platform deltaT windowWidth)
          (pt-col-extra? platform deltaT (- windowWidth)))
    )

    (define/private (pt-col-extra? platform deltaT offset)
      (let ([x (+ x offset)])
        (and 
          (> (+ x width)
            (send platform get-x))
          (< x 
            (+ (send platform get-x) (send platform get-width)))
          (<= (+ y height) 
              (send platform get-y))
          (>= (+ y height (* vy deltaT))
              (send platform get-y)))
        ))
        
      
      
      
    
    
    
          
    
    ))