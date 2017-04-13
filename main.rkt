#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")



;---INITIERA SPRITES----
(define player (new player% [x 10] [y 20] [height 50] [width 50]))
(send player load-texture "texture1.png")

(define platform (new platform% [x 70] [y 200] [width 100] [height 10]))
(send platform load-texture "img.png")

;---GLOBAL VARIABLES---
(define LEFT_DOWN #f)
(define RIGHT_DOWN #f)
(define nPlatforms 25)
(define platforms (for/vector ([i nPlatforms]) (new platform% 
                                            [x (* i 30)]
                                            [y (* i 50)]
                                            [width 100]
                                            [height 10])))


;---IMPORTANT FUNCTIONS---
(define (init-game)
  (for ([i nPlatforms])
      (send (vector-ref platforms i) load-texture "img.png")))

(define (update-game)
  (send canvas refresh)
  (player-physics))

(define (player-physics)
  (send player apply-gravity 0.016)

  (send player side-accelerate LEFT_DOWN RIGHT_DOWN 0.016)
  
  (if (send player platform-collission? platform 0.016)
    (begin (send player set-vy! -250)
           (send player set-y! (- (send platform get-y) (send player get-height)))
           (send platform load-texture "texture1.png"))
    (send platform load-texture "img.png"))
    
  (when (> (+ (send player get-height) (send player get-y)) (send canvas get-height))
    (send player set-vy! -250)
    (send player set-y! (- (send canvas get-height) (send player get-height))))
  
  (send player move 0.016)
  )
  


(define (drawing-proc lcanvas ldc)
  (send ldc clear)
  (send player draw ldc)
  (send platform draw ldc)
  (for ([i platforms])
      (send i draw ldc)))


;---CANVAS SKRÄP---
(define frame (new frame% 
                   [label "test"]
                   [width 300]
                   [height 300]))
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


