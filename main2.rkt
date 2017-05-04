#lang racket
(require racket/gui
         "sprite.rkt"
         "enemy.rkt"
         "platform.rkt"
         "player.rkt"
         "game-engine.rkt")
;---GLOBAL VARIABLES---
(define WINDOW_WIDTH (* 9 45))
(define WINDOW_HEIGHT (* 16 45))



;Initialize frame and engine
(define frame (new frame% 
                   [label "test"]
                   [width WINDOW_WIDTH]
                   [height WINDOW_HEIGHT]
                   [alignment '(center top)]))

;;---MENU ELEMENTS---
(define main-menu-panel (new vertical-panel%
    [parent frame]
    [border 10]
    [alignment '(center top)]
    [spacing 50]))
(define ng-button (new button%
    [parent main-menu-panel]
    [label "New game"]
    [callback (lambda (b e)
        (send game-engine initialize-game)
        (send game-engine load-sprite-textures)
        (send frame delete-child main-menu-panel)
        (send frame add-child game-panel)
        (send game-engine resume-game))]))

;;---INGAME ELEMENTS---
(define (game-over-proc final-score)
    (send frame delete-child game-panel)
    (send frame add-child main-menu-panel))

(define game-panel (new vertical-panel%
    [parent frame]
    [border 10]
    [alignment '(left bottom)]
    [spacing 50]
    ))

(define game-engine (new game-engine%
    [parent game-panel]
    [on-game-over game-over-proc]
    
    [FRAMERATE 30.0]
    [min-width WINDOW_WIDTH]
    [stretchable-width 0]
    [min-height (- WINDOW_HEIGHT 50)]

    [CANVAS_HEIGHT (- WINDOW_HEIGHT 50)]
    [CANVAS_WIDTH WINDOW_WIDTH]
    ))

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
    [callback (lambda (b e) 
        (send game-engine resume-game))]
    ))

;;---Highscore---


(send frame delete-child game-panel)

(send frame show #t)

