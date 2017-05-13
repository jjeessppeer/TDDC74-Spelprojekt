#lang racket
(require racket/gui)
(require racket/gui
         racket/draw
         "enemy.rkt"
         "platform.rkt"
         "player.rkt")
(provide game-engine%)

(define game-engine%
  (class canvas%
  (super-new)
    ;;Function used by the game-loop timer.
    ;;Updates the gamestate and measures the time between function calls.
    ;;Time is used to ensure game logic runs the same despite frametrate
    (define update-game-state
      (let ( [lastTime (current-milliseconds)] [currentTime (current-milliseconds)] )
        (lambda ()
          (set! currentTime (current-milliseconds))
          (when just-paused ;When the game has been paused the time differance should not be used
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
      [FRAMERATE 60.0])
    (field
      [player #f]
      [enemies #f]
      [platforms #f]
      [LEFT_DOWN #f]
      [RIGHT_DOWN #f]
      [HIGHEST_PLATFORM 0.0]
      [SCORE 0.0]
      [dc (send this get-dc)]
      [game-loop (new timer% [notify-callback update-game-state])]
      [GAME_START_TIME (current-milliseconds)]
      [just-paused #t]
      [uiHeart (make-object bitmap% "textures/heart.png" 'png/alpha #f #f 0.5)])

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
               (set! RIGHT_DOWN #f)])))

    ;;Initializes or resets all relevant variables and objects. 
    ;;Should always be called before starting a new game.
    (define/public (initialize-game)  
      (set! HIGHEST_PLATFORM 0.0)
      (set! SCORE 0.0)
      (set! RIGHT_DOWN #f)
      (set! LEFT_DOWN #f)
      (set! just-paused #t)
      
      ;;Initialize game objects
      (set! player 
        (new player% 
          [x 200] [y 200] 
          [height 20] [width 20] 
          [windowWidth CANVAS_WIDTH]
          [windowHeight CANVAS_HEIGHT]))

      (set! enemies (for/vector ([i 3]) 
        (new enemy% 
          [x (random CANVAS_WIDTH)] [y (- (random 3000))] 
          [CANVAS_WIDTH CANVAS_WIDTH]
          [height 50] [width 50]
          [enemyType (random 2)])))

      (set! platforms (for/vector ([i 25]) 
        (new platform% 
          [x (random CANVAS_WIDTH)] [y (* i 50)]
          [width 60] [height 10]
          [platformType (random 2)])))

      ;;Load sprite textures
      (send player load-texture "textures/player.png")
      (for ([enemy enemies])
        (send enemy load-texture "textures/enemy.png"))
      (for ([platform platforms])
        (if (= (send platform get-type) 0)
            (send platform load-texture "textures/platform1.png")
            (send platform load-texture "textures/platform2.png"))))

    ;;Updates the game state based on the time since the last update
    (define/private (step-logic deltaT)

      ;---Player logic---
      (send player apply-gravity deltaT)
      (send player apply-friction deltaT)
      (send player side-accelerate LEFT_DOWN RIGHT_DOWN deltaT)
      
      ;;Check if game-over conditions are met
      (when (send player is-dead?)
        (pause-game)
        (on-game-over (exact-round SCORE)))
        
      ;;When player is outside screen, move it to the other side.
      (when (< (send player get-x) 0)
        (send player set-x! CANVAS_WIDTH))
      (when (> (send player get-x) CANVAS_WIDTH)
        (send player set-x! 0))

      ;;When the player-position is in the upper portion of the screen
      ;;move all things downwards, else just move the player
      (if (and (< (send player get-y) (/ CANVAS_HEIGHT 4))
               (< (send player get-vy) 0))
          (begin (set! HIGHEST_PLATFORM (+ HIGHEST_PLATFORM (* (send player get-vy) deltaT -1)))
                 (for ([enemy enemies])
                   (send enemy move-by 0 (- (send player get-vy)) deltaT))
                 (for ([platform platforms]) 
                   (send platform move-by 0 (- (send player get-vy)) deltaT))
                 (set! SCORE (- SCORE (/ (send player get-vy) 100))))
          (send player move-y deltaT))
      (send player move-x deltaT)

      ;---Enemy logic---
      (for ([enemy enemies])
        (send enemy enemyAI player deltaT)
        (send enemy move deltaT)
        (when (> (send enemy get-y) CANVAS_HEIGHT) 
          (send enemy respawn))
        (when (send enemy collission? player deltaT) 
            (send enemy collission-proc player deltaT)))

      ;---Platform logic---
      (for ([platform platforms])
        (when (send platform collission? player deltaT)
          (send platform bounce player))
        (send platform move deltaT)
        (when (> (send platform get-y) CANVAS_HEIGHT) ;Move platform above screen
          (send platform set-y! (- HIGHEST_PLATFORM (+ 40 (random 40))))
          (set! HIGHEST_PLATFORM (send platform get-y))
          (send platform set-x! (random (- CANVAS_WIDTH (send platform get-width)))))))
        
    (define/override (on-paint)
      (send dc clear)
      (send player draw dc)
      (for ([enemy enemies])
        (send enemy draw dc))
      (for ([platform platforms])
        (send platform draw dc))
      (for ([i (send player get-health)]) 
        (send dc draw-bitmap uiHeart (- CANVAS_WIDTH (* (+ i 1) 40)) 10))
      (send dc draw-text (number->string (exact-round SCORE)) 20 10))
    
    (define/public (resume-game)
      (send game-loop start (exact-floor (* (/ 1 FRAMERATE) 1000)) #f))

    (define/public (pause-game)
      (set! just-paused #t)
      (send game-loop stop))
    
    ))