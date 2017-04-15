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
    (acc-x (/ (- (send player get-x) x) 3) deltaT)
    (acc-y (/ (- (send player get-y) y) 3) deltaT))
    
  (super-new)))



