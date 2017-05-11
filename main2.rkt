#lang racket
(require racket/gui
         "game-engine.rkt")

;---GLOBAL VARIABLES---
(define WINDOW_WIDTH (* 9 45))
(define WINDOW_HEIGHT (* 16 45))


;;Initialize frame which will hold all gui elements
(define frame (new frame% 
                   [label "Hoppspel 123"]
                   [width WINDOW_WIDTH]
                   [height WINDOW_HEIGHT]
                   [stretchable-height (+ WINDOW_HEIGHT 20)]
                   [stretchable-width (+ WINDOW_WIDTH 20)]
                   [alignment '(center top)]))

;;;---Main menu elements---

(define main-menu-panel (new vertical-panel%
    [min-width WINDOW_WIDTH]
    [min-height WINDOW_HEIGHT]
    [parent frame]
    [border 10]
    [alignment '(center top)]
    [spacing 10]
    ))

(define ng-button (new button%
    [parent main-menu-panel]
    [label "New game"]
    [callback (lambda (b e) ;Initializes a new game and swaps the showed panel
        (send game-engine initialize-game)
        (send game-engine load-sprite-textures)
        (send frame delete-child main-menu-panel)
        (send frame add-child game-panel)
        (send game-engine focus)
        (send game-engine resume-game))]))


(define highscore-table (new message%   ;Displays highscores in menu
    [parent main-menu-panel]
    [label "-"]
    [auto-resize #t]))

(define last-score (new message%
    [parent main-menu-panel]
    [label "Last score: -"]
    [auto-resize #t]))

;;;---Highscore functions---

(define highscores  (file->list "saved-data/highscore.txt"))

;Adds score to highscorelist. If size is larger than 8 remove worst score
(define (add-highscore score)
    (set! highscores
        (sort (cons score highscores) >))
    (when (> (length highscores) 8)
        (set! highscores (take highscores 8)))
    (display-lines-to-file 
        highscores 
        "saved-data/highscore.txt"
        #:exists 'replace))

;;Reload the highscores shown in main menu
(define (update-highscore-table)
    (send highscore-table set-label
        (string-join 
            (for/list ([i 8] [score highscores])
                (string-append (number->string (+ i 1)) 
                               ". " 
                               (number->string score)))
            "\n"
            #:before-first "Highscores: \n")))
    



;;---GAME---
(define game-panel (new vertical-panel%
    [parent frame]
    [border 10]
    [alignment '(left bottom)]
    [spacing 50]
    ))

(define game-engine (new game-engine%
    [parent game-panel]
    [on-game-over (lambda (final-score);Update highcores and return to main menu
        (add-highscore final-score)
        (update-highscore-table)
        (send last-score set-label (string-append "Last score: " (number->string final-score)))
        (send frame delete-child game-panel)
        (send frame add-child main-menu-panel))]
    [FRAMERATE 60.0]
    [min-width WINDOW_WIDTH]
    [stretchable-width 0]
    [min-height (- WINDOW_HEIGHT 50)]

    [CANVAS_HEIGHT (- WINDOW_HEIGHT 50)]
    [CANVAS_WIDTH WINDOW_WIDTH]
    ))

;;---Ingame menu---
(define game-menu-panel (new horizontal-panel%
    [parent game-panel]
    [border 10]
    [alignment '(left bottom)]
    [spacing 10]
    ))

(define menu-button (new button% 
    [parent game-menu-panel]
    [label "Main menu"]
    [callback (lambda (b e)
        (send game-engine pause-game)
        (send frame delete-child game-panel)
        (send frame add-child main-menu-panel))]))

(define pause-button (new button%
    [parent game-menu-panel]
    [label "Pause"]
    [callback (lambda (b e)
        (send game-engine pause-game))]))

(define resume-button (new button%
    [parent game-menu-panel]
    [label "Resume"]
    [callback (lambda (b e) 
        (send game-engine resume-game))]
    ))

;;Game should not show up on startup and it therefore removed
(send frame delete-child game-panel)

(update-highscore-table)

;;All startup initializations are done, show the frame.
(send frame show #t)