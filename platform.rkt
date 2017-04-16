#lang racket
(require "sprite.rkt")
(provide platform%)

(define platform%
  (class sprite%
    (init-field [platformType 0])
    (inherit-field x y
                   width height
                   )
    (define/public (get-type) platformType)


    (define/public (bounce player)
      (case platformType
        [(0) (send player set-vy! -400)]
        [(1) (send player set-vy! -650)]))
  
    
  (super-new)))



