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
(define player (new player% [x 10] [y 20] [height 50] [width 50]))
(send player load-texture "texture1.png")

(define platforms (for/vector ([i 25]) (new platform% 
                                            [x (random WINDOW_WIDTH)]
                                            [y (* i 50)]
                                            [width 100]
                                            [height 10]
                                            [platformType (random 2)])))





;---IMPORTANT FUNCTIONS---
(define (init-game)
  (for ([platform platforms])
    (if (= (send platform get-type) 0)
        (send platform load-texture "img.png")
        (send platform load-texture "texture1.png"))))

(define (update-game)
  (send canvas refresh)
  (player-physics))

(define (player-physics)
  (send player apply-gravity 0.016)
  (send player apply-friction 0.016)
  (send player side-accelerate LEFT_DOWN RIGHT_DOWN 0.016)
  
  (for ([platform platforms])
    (when (send player platform-collission? platform 0.016)
      (send platform bounce player))
    
    (when (> (send platform get-y) WINDOW_HEIGHT)
      (send platform set-y! -20)
      (send platform set-x! (random WINDOW_WIDTH)))
    )
  
  
    
  (when (> (+ (send player get-height) (send player get-y)) (send canvas get-height))
    (send player set-vy! -250)
    (send player set-y! (- (send canvas get-height) (send player get-height))))
  
  
  (if (and (< (send player get-y) (/ WINDOW_HEIGHT 4))
           (< (send player get-vy) 0))
      (for ([platform platforms]) (send platform move-by
                                        0
                                        (- (send player get-vy))
                                        0.016))
      (send player move-y 0.016))
  
  (send player move-x 0.016)
  )
  


(define (drawing-proc lcanvas ldc)
  (send ldc clear)
  (send player draw ldc)
  (for ([platform platforms])
      (send platform draw ldc)))


;---CANVAS SKRÄP---
(define frame (new frame% 
                   [label "test"]
                   [width 600]
                   [height 600]))
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


