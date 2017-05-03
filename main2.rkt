#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "enemy.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt"
         "game-engine.rkt")
;---GLOBAL VARIABLES---
(define WINDOW_WIDTH (* 9 45))
(define WINDOW_HEIGHT (* 16 45))

(define GAME_START_TIME (current-milliseconds))
(define SCORE 0)

;---INITIERA SPRITES----
(define player (new player% [x 200] [y 200] [height 20] [width 20] [windowWidth WINDOW_WIDTH]))

(define enemies (for/vector ([i 2]) (new enemy% [x 0] [y 0] [height 50] [width 50])))


(define platforms (for/vector ([i 25]) (new platform% 
                                            [x (random WINDOW_WIDTH)]
                                            [y (* i 50)]
                                            [width 60]
                                            [height 10]
                                            [platformType (random 2)])))



;---CANVAS SKRÄP---
(define frame (new frame% 
                   [label "test"]
                   [width WINDOW_WIDTH]
                   [height WINDOW_HEIGHT]))



(define game-engine (new game-engine%
    [parent frame]
    [player player]
    [enemies enemies]
    [platforms platforms]
    [FRAMERATE 60.0]
    [WINDOW_HEIGHT WINDOW_HEIGHT]
    [WINDOW_WIDTH WINDOW_WIDTH]

    ))

(send game-engine load-sprite-textures)

(send frame show #t)
(send game-engine resume-game)

