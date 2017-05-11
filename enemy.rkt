#lang racket
(require "sprite.rkt")
(provide enemy%)

(define enemy%
  (class sprite%
    (init-field 
      CANVAS_WIDTH
      [enemyType 0]
      [timeOfAttack 0]
      [attackCooldown 1000]
      )
    (inherit-field 
      x y
      vx vy
      width height)
    (inherit
      acc-x acc-y
      set-vx! set-vy!
      set-x! set-y!
      get-center-x get-center-y)
  
  (define/public (enemyAI player deltaT)
    (case enemyType
          [(0) ;Follow player
            (set-vx! (/ (- (send player get-x) x) 3))
            (set-vy! (/ (- (send player get-y) y) 3))]
          [(1) ;Move side to side
            (set-x! (+ (/ CANVAS_WIDTH 2) (* (/ CANVAS_WIDTH 2) (sin (/ (current-milliseconds) 1000)))))]))
    
  ;;Basic circular collission detection
  (define/public (collission? player deltaT)
    (and 
      (> (- (current-milliseconds) timeOfAttack) attackCooldown)
      (< (+ (expt (- (send player get-center-x) (get-center-x)) 2)
            (expt (- (send player get-center-y) (get-center-y)) 2))
         (/ (expt (+ (send player get-width) width) 2) 4))))
      
  (define/public (collission-proc player deltaT)
    (set! timeOfAttack (current-milliseconds))
    (case enemyType
      [(0) ;Knock player sideways
        (send player acc-x (* 600 (sgn (- (send player get-center-x) (get-center-x)))) 1)]
      [(1) ;Damage player
        (send player damage)])
      )
    
  (super-new)))



