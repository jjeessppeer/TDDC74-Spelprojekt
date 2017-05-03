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
  (class canvas%
    (super-new)

    (define (update-game-state)
        (step-logic 0.016)
        (drawing-proc))


    (init-field 

        
        
        player
        enemies
        platforms

        WINDOW_WIDTH
        WINDOW_HEIGHT
        
        on-game-over

        [dc (send this get-dc)]
        [FRAMERATE 60]
        [LEFT_DOWN #f]
        [RIGHT_DOWN #f]
        [HIGHEST_PLATFORM 0.0]
        [SCORE 0.0]
        

        [game-loop (new timer% [notify-callback update-game-state])]
        [GAME_START_TIME (current-milliseconds)]
        )



    (define/override (on-char key-event)
        (printf "click")
      (let ([key-code (send key-event get-key-code)]
                               [key-release-code (send key-event get-key-release-code)])
                           (cond [(eq? key-code 'left)
                                  (set! LEFT_DOWN #t)]
                                 [(eq? key-code 'right)
                                  (set! RIGHT_DOWN #t)]
                                 [(eq? key-release-code 'left)
                                  (set! LEFT_DOWN #f)]
                                 [(eq? key-release-code 'right)
                                  (set! RIGHT_DOWN #f)]
                                 [(eq? key-code 'up)
                                  (send player acc-y (- 250) 1)])
                           ))
    (define/override (on-event mouse-event)
      #f)


    (define/public (load-sprite-textures)
        (send player load-texture "textures/bild.png")
        (for ([enemy enemies])
            (send enemy load-texture "textures/enemy.png"))
        (for ([platform platforms])
            (if (= (send platform get-type) 0)
                (send platform load-texture "textures/img.png")
                (send platform load-texture "textures/hero.png"))))

    
    
    (define/private (step-logic deltaT)
        ;---Enemy stuff---
        (for ([enemy enemies])
            (send enemy enemyAI player deltaT)
            (when (send enemy collission? player deltaT) (send enemy collission-proc player deltaT))
            (send enemy move deltaT))
        
        ;---Player---
        (send player apply-gravity deltaT)
        (send player apply-friction deltaT)
        (send player side-accelerate LEFT_DOWN RIGHT_DOWN deltaT)
        
        (when (> (send player get-y) WINDOW_HEIGHT)
            (send player set-vy! -250)
            (pause-game)
            (on-game-over))
        
        (when (< (send player get-x) 0)
            (send player set-x! WINDOW_WIDTH))
        (when (> (send player get-x) WINDOW_WIDTH)
            (send player set-x! 0))
        
        
        
        
        ;---Platforms---
        (for ([platform platforms])
            (when (send platform collission? player deltaT)
            (send platform bounce player))
            
            (send platform move deltaT)

            (when (> (send platform get-y) WINDOW_HEIGHT)
            (send platform set-y! (- HIGHEST_PLATFORM (+ 40 (random 40))))
            (set! HIGHEST_PLATFORM (send platform get-y))
            (send platform set-x! (random (- WINDOW_WIDTH (send platform get-width)))))
            )

        ;;When the players position is in the upper portion of the screen, move all things downwards insdead of moving player upwards.
        (if (and (< (send player get-y) (/ WINDOW_HEIGHT 4))
                (< (send player get-vy) 0))
            (begin (set! HIGHEST_PLATFORM (+ HIGHEST_PLATFORM (* (send player get-vy) deltaT -1)))
                    (for ([enemy enemies])
                        (send enemy move-by 0 (- (send player get-vy)) deltaT))
                    (for ([platform platforms]) 
                        (send platform move-by 0 (- (send player get-vy)) deltaT)))
            (send player move-y deltaT))
        ;;No special behavior when moving in the x-direction
        (send player move-x deltaT)
    )

    (define/private (drawing-proc)
        (send dc clear)
        (send dc draw-text (number->string (/ (- (current-milliseconds) GAME_START_TIME) 1000.0)) 50 50)
        (send player draw dc)
        (for ([enemy enemies])
            (send enemy draw dc))
        (for ([platform platforms])
            (send platform draw dc)))


    (define/public (resume-game)
        (send game-loop start (exact-floor (* (/ 1 FRAMERATE) 1000)) #f))
    (define/public (pause-game)
        (send game-loop stop))
    
    
    
    
    
    
    
    
          
    
    
    ))