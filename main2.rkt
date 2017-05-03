#lang racket
(require racket/gui
         "sprite.rkt"
         "enemy.rkt"
         "platform.rkt"
         "player.rkt"
         "input-canvas.rkt"
         "game-engine.rkt")
;---GLOBAL VARIABLES---
(define WINDOW_WIDTH (* 9 45))
(define WINDOW_HEIGHT (* 16 45))


;---Initialize sprites----
(define player (new player% [x 200] [y 200] [height 20] [width 20] [windowWidth WINDOW_WIDTH]))

(define enemies (for/vector ([i 1]) (new enemy% [x 0] [y 0] [height 50] [width 50])))


(define platforms (for/vector ([i 25]) (new platform% 
                                            [x (random WINDOW_WIDTH)]
                                            [y (* i 50)]
                                            [width 60]
                                            [height 10]
                                            [platformType (random 2)])))

;Initialize frame and engine
(define frame (new frame% 
                   [label "test"]
                   [width WINDOW_WIDTH]
                   [height WINDOW_HEIGHT]
                   [alignment '(center top)]))

(define (game-over-proc final-score)
    (send frame delete-child game-engine))


(define game-panel (new vertical-panel%
    [parent frame]
    [border 10]
    [alignment '(left bottom)]
    [spacing 50]
    ))

(define game-engine (new game-engine%
    [parent game-panel]
    [player player]
    [enemies enemies]
    [platforms platforms]
    [on-game-over game-over-proc]
    
    [FRAMERATE 60.0]
    [min-width WINDOW_WIDTH]
    [stretchable-width 0]
    [min-height (- WINDOW_HEIGHT 50)]

    [CANVAS_HEIGHT (- WINDOW_HEIGHT 50)]
    [CANVAS_WIDTH WINDOW_WIDTH]
    ))
(send game-engine load-sprite-textures)


;;---Menu initializations---
(define game-menu-panel (new horizontal-panel%
    [parent game-panel]
    [border 10]
    [alignment '(left bottom)]
    [spacing 50]
    ))

(define mm-button (new button%
    [parent game-menu-panel]
    [label "Main menu"]
    [callback (lambda (button event)
        (send game-engine pause-game))]
    ))
(define re-button (new button%
    [parent game-menu-panel]
    [label "Resume"]
    [callback (lambda (button event) 
        (send game-engine resume-game)
        (send frame add-child game-engine))]
    ))

;;---Highscore---




(send frame show #t)

(send game-engine resume-game)
