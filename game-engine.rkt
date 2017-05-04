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

    ;;Measures the time since the last update, this time is used to ensure the 
    ;;game logic runs the same at any framerate
    (define update-game-state
      (let ( [lastTime (current-milliseconds)] [currentTime (current-milliseconds)] )
        (lambda ()
          (set! currentTime (current-milliseconds))
          ;; When the game has been paused the time differance should not be used
          (when just-paused
            (set! lastTime currentTime)
            (set! just-paused #f))
          (step-logic (/ (- currentTime lastTime) 1000))
          (refresh)
          (set! lastTime currentTime))))

    (inherit refresh)
    (init-field 
     CANVAS_WIDTH
     CANVAS_HEIGHT
        
     on-game-over

     [player #f]
     [enemies #f]
     [platforms #f]

     [dc (send this get-dc)]
     [FRAMERATE 60.0]
     [LEFT_DOWN #f]
     [RIGHT_DOWN #f]
     [HIGHEST_PLATFORM 0.0]
     [SCORE 0.0]

     [game-loop (new timer% [notify-callback update-game-state])]
     [GAME_START_TIME (current-milliseconds)]
     [just-paused #t]
     )



    (define/override (on-char key-event)
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

    ;;Initializes all relevant variables and objects. 
    ;;Should always be called before starting a new game.
    (define/public (initialize-game)  
      (set! HIGHEST_PLATFORM 0.0)
      (set! SCORE 0.0)
      (set! RIGHT_DOWN #f)
      (set! LEFT_DOWN #f)
      (set! just-paused #t)

      (set! player 
        (new player% 
          [x 200] [y 200] 
          [height 20] [width 20] 
          [windowWidth CANVAS_WIDTH]))

      (set! enemies (for/vector ([i 1]) 
        (new enemy% 
          [x 0] [y 0] 
          [height 50] [width 50])))   

      (set! platforms (for/vector ([i 25]) 
        (new platform% 
          [x (random CANVAS_WIDTH)] [y (* i 50)]
          [width 60] [height 10]
          [platformType (random 2)]))))

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
        (when (send enemy collission? player deltaT) 
            (send enemy collission-proc player deltaT))
        (send enemy move deltaT))
        
      ;---Player---
      (send player apply-gravity deltaT)
      (send player apply-friction deltaT)
      (send player side-accelerate LEFT_DOWN RIGHT_DOWN deltaT)
        
      (when (> (send player get-y) CANVAS_HEIGHT)
        (send player set-vy! -250)
        (pause-game)
        (on-game-over SCORE))
        
      (when (< (send player get-x) 0)
        (send player set-x! CANVAS_WIDTH))
      (when (> (send player get-x) CANVAS_WIDTH)
        (send player set-x! 0))

      ;;When the players position is in the upper portion of the screen
      ;;move all things downwards instead of moving player upwards.
      (if (and (< (send player get-y) (/ CANVAS_HEIGHT 4))
               (< (send player get-vy) 0))
          (begin (set! HIGHEST_PLATFORM (+ HIGHEST_PLATFORM (* (send player get-vy) deltaT -1)))
                 (for ([enemy enemies])
                   (send enemy move-by 0 (- (send player get-vy)) deltaT))
                 (for ([platform platforms]) 
                   (send platform move-by 0 (- (send player get-vy)) deltaT))
                 (set! SCORE (- SCORE (/ (send player get-vy) 100))))
          (send player move-y deltaT))
      ;;No special behavior when moving in the x-direction.
      (send player move-x deltaT)
      ;---Platforms---
      (for ([platform platforms])
        (when (send platform collission? player deltaT)
          (send platform bounce player))
            
        (send platform move deltaT)

        (when (> (send platform get-y) CANVAS_HEIGHT)
          (send platform set-y! (- HIGHEST_PLATFORM (+ 40 (random 40))))
          (set! HIGHEST_PLATFORM (send platform get-y))
          (send platform set-x! (random (- CANVAS_WIDTH (send platform get-width)))))
        )

        
    
      )
        
    (define/override (on-paint)
      (send dc clear)
      (send dc draw-text (number->string (exact-round SCORE)) 50 50)
      (send player draw dc)
      (for ([enemy enemies])
        (send enemy draw dc))
      (for ([platform platforms])
        (send platform draw dc)))
    
    (define/public (resume-game)
      (send game-loop start (exact-floor (* (/ 1 FRAMERATE) 1000)) #f))

    (define/public (pause-game)
      (set! just-paused #t)
      (send game-loop stop))
    
    
    
    
    
    
    
    
          
    
    
    ))