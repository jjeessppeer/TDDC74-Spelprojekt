#lang racket
(require racket/gui
         racket/draw
         "sprite.rkt"
         "platform.rkt")
(provide input-canvas%)

(define input-canvas%
  (class canvas%
    (init-field keyboard-handler
                mouse-handler)
    (define/override (on-char key-event)
      (keyboard-handler key-event))
    (define/override (on-event mouse-event)
      (mouse-handler mouse-event))
    (super-new)))