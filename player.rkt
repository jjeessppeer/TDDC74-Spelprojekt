#lang racket
(require racket/gui
         "sprite.rkt")
(provide player%)

(define player%
  (class sprite%
    (init-field [onGround #f]
                [gravityAcc 500]
                [sideAcc 500]
                )
    
    (define/public (apply-gravity deltaT)
      (send this acc-y gravityAcc deltaT))
    
    (define/public (apply-friction deltaT)
      (send this set-vx! (* (send this get-vx) (expt 0.3 deltaT))))
    
    (define/public (side-accelerate LD RD deltaT)
      (when (xor LD RD)
        (let ([direction (if LD -1 1)])
          (send this acc-x (* direction sideAcc) deltaT))
        ))
          
          
    
    (define/public (platform-collission? platform deltaT);platform collision 
      (and 
       (> (+ (send this get-x) (send this get-width)) 
          (send platform get-x))
       (< (send this get-x) 
          (+ (send platform get-x) (send platform get-width)))
       (<= (+ (send this get-y) (send this get-height)) 
           (send platform get-y))
       (>= (+ (send this get-y) (send this get-height) (* (send this get-vy) deltaT))
           (send platform get-y))))
      
      
      
      
    
    
    
          
    
    
    (super-new)))