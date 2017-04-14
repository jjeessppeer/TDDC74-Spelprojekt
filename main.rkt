#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")

;---GLOBAL VARIABLES---
(define LEFT_DOWN #f)
(define RIGHT_DOWN #f)
(define WINDOW_WIDTH 500)
(define WINDOW_HEIGHT 500)

;---INITIERA SPRITES----
(define player (new player% [x 10] [y 20] [height 50] [width 50] [windowWidth WINDOW_WIDTH]))




(define platforms (for/vector ([i 10]) (new platform% 
                                            [x (random WINDOW_WIDTH)]
                                            [y (* i 50)]
                                            [width 100]
                                            [height 10]
                                            [platformType (random 2)])))


;---IMPORTANT FUNCTIONS---
(define (init-game)

  (send player load-texture "texture1.png")
  (for ([platform platforms])
    (if (= (send platform get-type) 0)
        (send platform load-texture "img.png")
        (send platform load-texture "texture1.png"))))

(define lastTime (current-milliseconds))
(define currentFPS 0)
(define (update-game)
  (define deltaT (- (current-milliseconds) lastTime))
  (set! lastTime (current-milliseconds))
  (set! currentFPS (/ 1.0 (/ deltaT 1000)))
  (send canvas refresh)
  (player-physics (/ deltaT 1000)))


(define (player-physics deltaT)
  (send player apply-gravity deltaT)
  (send player apply-friction deltaT)
  (send player side-accelerate LEFT_DOWN RIGHT_DOWN deltaT)
  
  (for ([platform platforms])
    (when (send player platform-collission? platform deltaT)
      (send platform bounce player))
    
    (when (> (send platform get-y) WINDOW_HEIGHT)
      (send platform set-y! -20)
      (send platform set-x! (random WINDOW_WIDTH))))
      
  
  
    
  (when (> (+ (send player get-height) (send player get-y)) WINDOW_HEIGHT)
    (send player set-vy! -250)
    (send player set-y! (- WINDOW_HEIGHT (send player get-height))))

  (when (< (send player get-x) 0)
    (send player set-x! WINDOW_WIDTH))
  (when (> (send player get-x) WINDOW_WIDTH)
    (send player set-x! 0))
  
  
  (if (and (< (send player get-y) (/ WINDOW_HEIGHT 4))
           (< (send player get-vy) 0))
      (for ([platform platforms]) (send platform move-by
                                        0
                                        (- (send player get-vy))
                                        deltaT))
      (send player move-y deltaT))
  
  (send player move-x deltaT))

  


(define (drawing-proc canvas dc)
  (send dc clear)
  (send player draw dc)
  (send dc draw-text (number->string currentFPS) 50 50)
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


