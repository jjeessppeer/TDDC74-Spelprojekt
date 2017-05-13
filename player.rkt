#lang racket
(require "sprite.rkt")
(provide player%)

(define player%
  (class sprite%
    (init-field 
      windowWidth
      windowHeight)
    (field
      [health 3]
      [onGround #f]
      [gravityAcc 500]
      [sideAcc 1000])
    (inherit-field 
      x y
      width height
      vx vy
      scaleX scaleY angle
      image)
    (inherit 
      acc-x acc-y
      set-vx!)
    
    ;;Special draw function for player to draw on both edges of the screen
    (define/override (draw dc)
          (send dc rotate angle)
          (send dc scale scaleX scaleY)
          (send dc draw-bitmap image (/ (+ x windowWidth) scaleX) (/ y scaleY))
          (send dc draw-bitmap image (/ (- x windowWidth) scaleX) (/ y scaleY))
          (send dc draw-bitmap image (/ x scaleX) (/ y scaleY))
          (send dc scale (/ 1 scaleX) (/ 1 scaleY))
          (send dc rotate (- angle)))

    (define/public (apply-gravity deltaT)
      (acc-y gravityAcc deltaT))
    
    (define/public (apply-friction deltaT)
      (set-vx! (* vx (expt 0.1 deltaT))))
    
    ;;Accelerates player sideways based on keyboard input
    (define/public (side-accelerate LD RD deltaT)
      (when (xor LD RD)
        (let ([direction (if LD -1 1)])
          (acc-x (* direction sideAcc) deltaT))))
    
    (define/public (get-health) health)
    (define/public (damage)
      (set! health (- health 1)))

    (define/public (is-dead?)
      (or 
        (<= health 0)
        (> y windowHeight)))

          
    (super-new)))