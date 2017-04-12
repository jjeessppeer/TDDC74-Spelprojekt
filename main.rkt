#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt")

;;TODO scale funkar inte som den ska.
(define frame (new frame% 
                   [label "test"]
                   [width 300]
                   [height 300]))

(define (update-game)
  (send canvas refresh)
  (player-physics)
  )


(define (player-physics)
  
  (when (send player platform-collission? platform)
    (send player set-vy 0)
    (send player set-y! (- (send platform get-y) (send player get-height))))
  
  (send player move 0.016)
  (if (> (+ (send player get-height) (send player get-y)) (send canvas get-height))
      (send player set-y! (- (send canvas get-height) (send player get-height)))
      (send player apply-gravity 0.016)))


(define (drawing-proc lcanvas ldc)
  (send ldc clear)
  (send player draw ldc)
  (send platform draw ldc))

(define canvas (new input-canvas% 
                    [paint-callback drawing-proc]
                    [parent frame] 
                    
                    [keyboard-handler 
                     (let ([count 0]) 
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
                           (printf "Keypress ~v \n" key-code)
                           (set! count (+ count 1)))))] 
                    
                    [mouse-handler (lambda (x) 1)]))








(define player (new player% [x 10] [y 20] [height 100] [width 100]))
(send player load-texture "texture1.png")

(define platform (new platform% [x 70] [y 200]))
(send platform load-texture "img.png")
(send platform set-width! 200)
(send platform set-height! 200)


(send frame show #t)

(define game-loop (new timer%
                       [notify-callback update-game]))
(send game-loop start 16 #f)


