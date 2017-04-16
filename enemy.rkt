#lang racket
(require "sprite.rkt")
(provide enemy%)

(define enemy%
  (class sprite%
    (init-field 
      [enemyType 0])
    (inherit-field 
      x y
      vx vy
      width height)
    (inherit
      acc-x acc-y
      set-vx! set-vy!
      get-center-x get-center-y)
  
  (define/public (enemyAI player deltaT)
    (set-vx! (/ (- (send player get-x) x) 3))
    (set-vy! (/ (- (send player get-y) y) 3)))

  (define/public (collission? player deltaT)
    (< (+ (expt (- (send player get-center-x) (get-center-x)) 2)
          (expt (- (send player get-center-y) (get-center-y)) 2))
       (/ (expt (+ (send player get-width) width) 2) 4)))

  (define/public (collission-proc player deltaT)
      (send player acc-x (* 10000 (sgn (- (send player get-center-x) (get-center-x)))) deltaT))
    
  (super-new)))



