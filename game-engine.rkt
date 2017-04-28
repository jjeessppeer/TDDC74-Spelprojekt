#lang racket
(require racket/gui)
(require racket/gui
         racket/draw
         "sprite.rkt"
         "enemy.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")
(provide game-engine%)

(define game-engine%
  (class object%
    (super-new)
    (init-field 

        [frame]
        [canvas]
        [dc]

        [FRAMERATE 60]
        [WINDOW_WIDTH]
        [WINDOW_HEIGHT]
        [LEFT_DOWN #f]
        [RIGHT_DOWN #f]
        [HIGHEST_PLATFORM 0.0]

        [player]
        [enemies]
        [platforms]

        [loopTimer]
        
        )


    (define/private (update-game-state deltaT)
        (step-logic deltaT)
        (drawing-proc canvas dc))
    
    (define/private (step-logic deltaT)
        ;---Enemy stuff---
        (send enemy enemyAI player deltaT)
        (when (send enemy collission? player deltaT) (send enemy collission-proc player deltaT))
        (send enemy move deltaT)

        ;---Player---
        (send player apply-gravity deltaT)
        (send player apply-friction deltaT)
        (send player side-accelerate LEFT_DOWN RIGHT_DOWN deltaT)
        
        (when (> (send player get-y) WINDOW_HEIGHT)
            (send player set-vy! -250)
            (send game-loop stop))
        
        (when (< (send player get-x) 0)
            (send player set-x! WINDOW_WIDTH))
        (when (> (send player get-x) WINDOW_WIDTH)
            (send player set-x! 0))


        ;---Platforms---
        (for ([platform platforms])
            (when (send player platform-collission? platform deltaT)
            (send platform bounce player))
            
            (send platform move deltaT)

            (when (> (send platform get-y) WINDOW_HEIGHT)
            (send platform set-y! (- HIGHEST_PLATFORM (+ 40 (random 40))))
            (set! HIGHEST_PLATFORM (send platform get-y))
            (send platform set-x! (random (- WINDOW_WIDTH (send platform get-width)))))
            )

    (define (drawing-proc canvas dc)
        (send dc clear)
        (send player draw dc)
        (send enemy draw dc)
        (send dc draw-text (number->string (/ (- (current-milliseconds) GAME_START_TIME) 1000.0)) 50 50)
        (for ([platform platforms])
            (send platform draw dc)))


    (define/public (resume-game)
        (send loopTimer start (* (/ 1 FRAMERATE) 1000) #f))
    (define/public (pause-game)
        (sent gameTimer stop))
    
    
    
    
    
    
    
    
          
    
    
    ))