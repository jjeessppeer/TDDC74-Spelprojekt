#lang racket
(require "sprite.rkt")
(provide platform%)

(define platform%
  (class sprite%
    (init-field [bounce-proc (lambda (player) (void))]
                [platformType 0]
                )
    (define/public (get-type) platformType)
    
    (define/public (bounce player)
      (case platformType
        [(0) (send player set-vy! -300)]
        [(1) (send player set-vy! -600)]))
  
    
  (super-new)))



