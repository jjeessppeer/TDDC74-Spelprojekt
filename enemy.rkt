#lang racket
(require "sprite.rkt")
(provide enemy%)

(define enemy%
  (class sprite%
    (init-field 
      )
    (inherit-field 
      x y
      vx vy)
    (inherit
      acc-x acc-y)
  
  (define/public (enemyAI player deltaT)
    (set-vx! (/ (- (send player get-x) x) 3) deltaT)
    (set-vy! (/ (- (send player get-y) y) 3) deltaT))
    
  (super-new)))



