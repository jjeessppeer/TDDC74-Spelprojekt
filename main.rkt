#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "enemy.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")

;---GLOBAL VARIABLES---
(define LEFT_DOWN #f)
(define RIGHT_DOWN #f)
(define WINDOW_WIDTH (* 9 45))
(define WINDOW_HEIGHT (* 16 45))

(define HIGHEST_PLATFORM 0.0)
(define GAME_START_TIME (current-milliseconds))
(define SCORE 0)

;---INITIERA SPRITES----
(define player (new player% [x 200] [y 200] [height 20] [width 20] [windowWidth WINDOW_WIDTH]))

(define enemy (new enemy% [x 0] [y 0] [height 50] [width 50]))


(define platforms (for/vector ([i 25]) (new platform% 
                                            [x (random WINDOW_WIDTH)]
                                            [y (* i 50)]
                                            [width 60]
                                            [height 10]
                                            [platformType (random 2)])))


;---IMPORTANT FUNCTIONS---
(define (init-game)
  (send enemy load-texture "textures/enemy.png")
  (send player load-texture "textures/bild.png")
  (for ([platform platforms])
    (if (= (send platform get-type) 0)
        (send platform load-texture "textures/img.png")
        (send platform load-texture "textures/hero.png"))))

(define lastTime (current-milliseconds))
(define currentFPS 0)
(define (update-game)
  (define deltaT (- (current-milliseconds) lastTime))
  (set! lastTime (current-milliseconds))
  (set! currentFPS (/ 1.0 (/ deltaT 1000)))
  (send canvas refresh)
  (player-physics (/ deltaT 1000)))


(define (player-physics deltaT)
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
    (when (send platform collission? player deltaT)
      (send platform bounce player))
    
    (send platform move deltaT)

    (when (> (send platform get-y) WINDOW_HEIGHT)
      (send platform set-y! (- HIGHEST_PLATFORM (+ 40 (random 40))))
      (set! HIGHEST_PLATFORM (send platform get-y))
      (send platform set-x! (random (- WINDOW_WIDTH (send platform get-width)))))
    )
      
  
  
  (if (and (< (send player get-y) (/ WINDOW_HEIGHT 4))
           (< (send player get-vy) 0))
      (begin (set! HIGHEST_PLATFORM (+ HIGHEST_PLATFORM (* (send player get-vy) deltaT -1)))
             (send enemy move-by 0 (- (send player get-vy)) deltaT)
             (for ([platform platforms]) 
                (send platform move-by 0 (- (send player get-vy)) deltaT)))
      (send player move-y deltaT))
  (send player move-x deltaT))

  


(define (drawing-proc canvas dc)
  (send dc clear)
  (send player draw dc)
  (send enemy draw dc)
  (send dc draw-text (number->string (/ (- (current-milliseconds) GAME_START_TIME) 1000.0)) 50 50)
  (for ([platform platforms])
      (send platform draw dc)))


;---CANVAS SKRÄP---
(define frame (new frame% 
                   [label "test"]
                   [width WINDOW_WIDTH]
                   [height WINDOW_HEIGHT]))
(define canvas (new input-canvas% 
                    [paint-callback drawing-proc]
                    [parent frame] 
                    
                    [keyboard-handler 
                       (lambda (key-event)
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
                           ))] 
                    
                    [mouse-handler (lambda (x) 1)]))



;---STARTA SAKER---
(init-game)
(send frame show #t)
(define game-loop (new timer%
                       [notify-callback update-game]))
(send game-loop start 16 #f)


