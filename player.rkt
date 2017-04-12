#lang racket
(require racket/gui
         "sprite.rkt")
(provide player%)

(define player%
  (class sprite%
    (init-field [onGround #f]
                [gravityAcc 500])
    
    (define/public (apply-gravity deltaT)
      (send this accelerate 0 (* gravityAcc deltaT)))
    
    (define/public (platform-collission? platform);Ground/platform collision 
      (and
       (and (> (+ (send this get-x) (send this get-width)) 
               (send platform get-x))
            (< (send this get-x) 
               (+ (send platform get-x) (send platform get-width))))
       (and (< (+ (send this get-y) (send this get-height)) 
               (send platform get-y))
            (> (+ (send this get-y) (send this get-height) (send this get-vy)) 
               (send platform get-y)))))
    
    
          
    
    
    (super-new)))