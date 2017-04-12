#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")

;;TODO scale funkar inte som den ska.


;---INITIERA SPRITES----
(define player (new player% [x 10] [y 20] [height 50] [width 50]))
(send player load-texture "texture1.png")

(define platform (new platform% [x 70] [y 200] [width 100] [height 10]))
(send platform load-texture "img.png")


;---IMPORTANT FUNCTIONS---
(define (update-game)
  (send canvas refresh)
  (player-physics)
  )


(define (player-physics)
  (send player apply-gravity 0.016)
  
  (when (send player platform-collission? platform)
    (send player set-vy! 0)
    (send player set-y! (- (send platform get-y) (send player get-height))))
    
  (when (> (+ (send player get-height) (send player get-y)) (send canvas get-height))
    (send player set-vy! 0)
    (send player set-y! (- (send canvas get-height) (send player get-height))))
  
  (send player move 0.016)
  )
  


(define (drawing-proc lcanvas ldc)
  (send ldc clear)
  (send player draw ldc)
  (send platform draw ldc)
  )


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
                         (let ([key-code (send key-event get-key-code)])
                           (when (eq? key-code 'left)
                             (send player accelerate -10 0)
                             (send player load-texture "img.png"))
                           (when (eq? key-code 'right)
                             (send player accelerate 10 0)
                             (send player load-texture "texture1.png"))
                           (when (eq? key-code 'up)
                             (send player accelerate 0 (- 250)))
                           ))] 
                    
                    [mouse-handler (lambda (x) 1)]))



;---STARTA SAKER---
(send frame show #t)
(define game-loop (new timer%
                       [notify-callback update-game]))
(send game-loop start 16 #f)


