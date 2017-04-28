#lang racket
(require "sprite.rkt")
(provide platform%)

(define platform%
  (class sprite%
    (init-field [platformType 0])
    (inherit-field x y
                   width height
                   )
    (inherit
      get-right-x get-bottom-y)

      
    (define/public (get-type) platformType)


    (define/public (collission? player deltaT)
        (and 
          (> (send player get-right-x)
             x)
          (< (send player get-x) 
            (get-right-x))
          (<= (send player get-bottom-y) 
              y)
          (>= (+ (send player get-bottom-y) (* (send player get-vy) deltaT))
              y)
        ))




    (define/public (bounce player)
      (case platformType
        [(0) (send player set-vy! -400)]
        [(1) (send player set-vy! -650)]))
  
    
  (super-new)))



