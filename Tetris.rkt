;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Tetris) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
 
; Data Definitions

;;; A Brick is a (make-brick Number Number Color)

(define-struct brick [x y color])

;(define (brick-temp sq)
;(...(brick-x sq)...)
;(...(brick-y sq)...)
;(...(brick-color sq)...))

(define sq1 (make-brick 20 30 "pink"))

;---------------------------------------------------------------------------------------------------

;;; A Pt (2D point) is a (make-posn Integer Integer)

;(define (pt-temp pt)
;(...(posn-x sq)...)
;(...(posn-y sq)...))

;;; A Bricks (Set of Bricks) is one of
;;; - '()
;;; - (cons Brick Bricks)
;;; Order does not matter.

;(define (bricks-temp bricks)
; (cond [(empty? bricks) ...]
;      [else (brick-temp(first bricks)) ... (bricks-temp (rest bricks)) ...]))

;---------------------------------------------------------------------------------------------------

;;; A NELOB (Non-Empty List of Bricks) is one of:
;(cons Brick '())
;(cons Brick NELOB)
;note: every NELOB is a Bricks

;(define (nelob-temp nelob)
;  (cond [(empty? (rest nelob)) (brick-temp (first nelob))]
;        [else ... (brick-template (first nelob)) ... (nelob-template rest nelob)]))

(define FULL-ROW-BOTT
  (list
   (make-brick 0  0 "goldenrod")
   (make-brick 1  0 "goldenrod")
   (make-brick 2  0 "goldenrod")
   (make-brick 3  0 "goldenrod")
   (make-brick 4  0 "goldenrod")
   (make-brick 5  0 "goldenrod")
   (make-brick 6  0 "goldenrod")
   (make-brick 7  0 "goldenrod")
   (make-brick 8  0 "goldenrod")
   (make-brick 9  0 "goldenrod")))

(define FULL-ROW-Y=1
  (list
   (make-brick 0  1 "purple")
   (make-brick 1  1 "purple")
   (make-brick 2  1 "purple")
   (make-brick 3  1 "purple")
   (make-brick 4  1 "purple")
   (make-brick 5  1 "purple")
   (make-brick 6  1 "purple")
   (make-brick 7  1 "purple")
   (make-brick 8  1 "purple")
   (make-brick 9  1 "purple")))

(define FULL-ROW-Y=0&1 (append FULL-ROW-BOTT FULL-ROW-Y=1))

;---------------------------------------------------------------------------------------------------

;;; A Tetra is a (make-tetra Pt NELOB)

;;; The center point is the point around which the tetra
;;; rotates when it spins.

(define-struct tetra [center bricks])
;(define (tetra-temp tetra)
;(...(pt-temp(tetra-center tetra))...)
;(...(nelob-temp(tetra-bricks tetra))...))

(define LEFT-EDGE-TETRA (make-tetra (make-posn .5 12.5)
                                    (cons (make-brick 0 12 'purple)
                                          (cons (make-brick 1 12 'purple)
                                                (cons (make-brick 0 13 'purple)
                                                      (cons (make-brick 0 14 'purple) '()))))))
(define RIGHT-EDGE-TETRA (make-tetra (make-posn 9.5 12.5)
                                     (cons (make-brick 9 12 'cyan)
                                           (cons (make-brick 8 12 'cyan)
                                                 (cons (make-brick 9 13 'cyan)
                                                       (cons (make-brick 9 14 'cyan) '()))))))
(define OFFLEFT (make-tetra (make-posn -1.5 12.5)
                            (cons (make-brick -2 12 'purple)
                                  (cons (make-brick -1 12 'purple)
                                        (cons (make-brick -2 13 'purple)
                                              (cons (make-brick -2 14 'purple) '()))))))
(define OFFRIGHT (make-tetra (make-posn 11.5 12.5)
                             (cons (make-brick 11 12 'cyan)
                                   (cons (make-brick 10 12 'cyan)
                                         (cons (make-brick 11 13 'cyan)
                                               (cons (make-brick 11 14 'cyan) '()))))))
(define ONE-BRICK (make-tetra (make-posn 10.5 13.5) (cons (make-brick 12 14 'red) '())))

(define BOTTOM-TETRA (make-tetra (make-posn 4 0.5)
                                 (cons (make-brick 4 0 'blue)
                                       (cons (make-brick 4 1 'orange) '()))))

(define LANDED-TETRA (make-tetra (make-posn 4 2)
                                 (list (make-brick 3 2 'pink)
                                       (make-brick 4 2 'green)
                                       (make-brick 5 2 'red))))

(define CW-ROTATED-LEFT-EDGE (make-tetra (make-posn 0.5 12.5)
                                         (cons (make-brick 0 13 'purple)
                                               (cons (make-brick 0 12 'purple)
                                                     (cons (make-brick 1 13 'purple)
                                                           (cons (make-brick 2 13 'purple) '()))))))
(define CCW-ROTATED-RIGHT-EDGE (make-tetra (make-posn 9.5 12.5)
                                           (cons (make-brick 10 12 'cyan)
                                                 (cons (make-brick 10 11 'cyan)
                                                       (cons (make-brick 9 12 'cyan)
                                                             (cons (make-brick 8 12 'cyan) '()))))))
(define CW-ROTATED-RIGHT-EDGE (make-tetra (make-posn 9.5 12.5)
                                          (cons (make-brick 9 13 'cyan)
                                                (cons (make-brick 9 14 'cyan)
                                                      (cons (make-brick 10 13 'cyan)
                                                            (cons (make-brick 11 13 'cyan) '()))))))
(define OFFLEFT2 (make-tetra (make-posn -.5 5.5)
                             (cons (make-brick -1 5 'red)
                                   (cons (make-brick -1 6 'red) '()))))
;---------------------------------------------------------------------------------------------------
(define BOARD-HEIGHT 20)
(define BOARD-WIDTH  10)
(define PIXELS/CELL 20)
(define BOARD (empty-scene (* BOARD-WIDTH PIXELS/CELL) (* BOARD-HEIGHT PIXELS/CELL)))

(define O-COLOR 'green)
(define I-COLOR 'blue)
(define L-COLOR 'purple)
(define J-COLOR 'cyan)
(define T-COLOR 'orange)
(define Z-COLOR 'pink)
(define S-COLOR 'red)

(define O-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid O-COLOR)))
(define I-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid I-COLOR)))
(define L-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid L-COLOR)))
(define J-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid J-COLOR)))
(define T-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid T-COLOR)))
(define Z-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid Z-COLOR)))
(define S-BRICK-IMG
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid S-COLOR)))

; Bricks that make up "O"
(define O-BRICK-1 (make-brick 4 21 O-COLOR))
(define O-BRICK-2 (make-brick 5 21 O-COLOR))
(define O-BRICK-3 (make-brick 4 22  O-COLOR))
(define O-BRICK-4 (make-brick 5 22  O-COLOR))

(define O-PT (make-posn 4.5 21.5))
(define O-BRICKS (list O-BRICK-1 O-BRICK-2 O-BRICK-3 O-BRICK-4))
(define O-TETRA (make-tetra O-PT O-BRICKS))

; Bricks that make up "I"
(define I-BRICK-1 (make-brick 3 21 I-COLOR))
(define I-BRICK-2 (make-brick 4 21 I-COLOR))
(define I-BRICK-3 (make-brick 5 21 I-COLOR))
(define I-BRICK-4 (make-brick 6 21 I-COLOR))

(define I-PT (make-posn 4 21))
(define I-BRICKS (list I-BRICK-1 I-BRICK-2 I-BRICK-3 I-BRICK-4))
(define I-TETRA (make-tetra I-PT I-BRICKS))

; Bricks that make up "L"
(define L-BRICK-1 (make-brick 3 21 L-COLOR))
(define L-BRICK-2 (make-brick 4 21 L-COLOR))
(define L-BRICK-3 (make-brick 5 21 L-COLOR))
(define L-BRICK-4 (make-brick 5 22 L-COLOR))

(define L-PT (make-posn 4.5 21.5))
(define L-BRICKS (list L-BRICK-1 L-BRICK-2 L-BRICK-3 L-BRICK-4))
(define L-TETRA (make-tetra L-PT L-BRICKS))

; Bricks that make up "J"
(define J-BRICK-1 (make-brick 3 22 J-COLOR))
(define J-BRICK-2 (make-brick 3 21 J-COLOR))
(define J-BRICK-3 (make-brick 4 21 J-COLOR))
(define J-BRICK-4 (make-brick 5 21 J-COLOR))

(define J-PT (make-posn 3.5 21.5))
(define J-BRICKS (list J-BRICK-1 J-BRICK-2 J-BRICK-3 J-BRICK-4))
(define J-TETRA (make-tetra J-PT J-BRICKS))

; Bricks that make up "T"
(define T-BRICK-1 (make-brick 3 21 T-COLOR))
(define T-BRICK-2 (make-brick 4 21 T-COLOR))
(define T-BRICK-3 (make-brick 4 22 T-COLOR))
(define T-BRICK-4 (make-brick 5 21 T-COLOR))

(define T-PT (make-posn 4.5 21.5))
(define T-BRICKS (list T-BRICK-1 T-BRICK-2 T-BRICK-3 T-BRICK-4))
(define T-TETRA (make-tetra T-PT T-BRICKS))

; Bricks that make up "Z"
(define Z-BRICK-1 (make-brick 3 22 Z-COLOR))
(define Z-BRICK-2 (make-brick 4 22 Z-COLOR))
(define Z-BRICK-3 (make-brick 4 21 Z-COLOR))
(define Z-BRICK-4 (make-brick 5 21 Z-COLOR))

(define Z-PT (make-posn 3.5 21.5))
(define Z-BRICKS (list Z-BRICK-1 Z-BRICK-2 Z-BRICK-3 Z-BRICK-4))
(define Z-TETRA (make-tetra Z-PT Z-BRICKS))

; Bricks that make up "S"
(define S-BRICK-1 (make-brick 3 21 S-COLOR))
(define S-BRICK-2 (make-brick 4 21 S-COLOR))
(define S-BRICK-3 (make-brick 4 22 S-COLOR))
(define S-BRICK-4 (make-brick 5 22 S-COLOR))

(define S-PT (make-posn 4.5 21.5))
(define S-BRICKS (list S-BRICK-1 S-BRICK-2 S-BRICK-3 S-BRICK-4))
(define S-TETRA (make-tetra S-PT S-BRICKS))

;---------------------------------------------------------------------------------------------------

;;; A World is a (make-world Tetra Bricks)
;;; The set of bricks represents the pile of bricks
;;; at the bottom of the screen.

;(define (world-temp world)
;  (tetra-temp(world-tetra w)...)
;  (bricks-temp(world-pile w)...)

(define-struct world [tetra pile])

(define BOTT-ROW-WORLD (make-world O-TETRA FULL-ROW-BOTT))
(define FIRST-ROW-WORLD (make-world S-TETRA FULL-ROW-Y=1))
(define BOTT/FIRST-ROW-WORLD (make-world S-TETRA FULL-ROW-Y=0&1))

;---------------------------------------------------------------------------------------------------

; Signature: place-image/cell: Image Number Number Image -> Image
; Purpose: place-image but with cell coordinates, not pixels

(define (place-image/cell i1 x y i2)
  (place-image i1
               (* PIXELS/CELL (+ x 1/2))
               (* PIXELS/CELL (- BOARD-HEIGHT (+ y 1/2)))
               i2))

(check-expect (place-image/cell O-BRICK-IMG 3 6 BOARD)
              (place-image O-BRICK-IMG
                           (* PIXELS/CELL (+ 3 1/2))
                           (* PIXELS/CELL (- BOARD-HEIGHT (+ 6 1/2)))
                           BOARD))
(check-expect (place-image/cell S-BRICK-IMG 4 7 BOARD)
              (place-image S-BRICK-IMG
                           (* PIXELS/CELL (+ 4 1/2))
                           (* PIXELS/CELL (- BOARD-HEIGHT (+ 7 1/2)))
                           BOARD))

; Signature: draw-brick: Brick -> Image
; Purpose: Render brick image based on Brick struct

(define (draw-brick sq)
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid (brick-color sq))))

(check-expect (draw-brick (make-brick 5 10 O-COLOR))
              (overlay (square PIXELS/CELL 'outline 'black)
                       (square PIXELS/CELL 'solid O-COLOR)))
(check-expect (draw-brick (make-brick 6 12 I-COLOR))
              (overlay (square PIXELS/CELL 'outline 'black)
                       (square PIXELS/CELL 'solid I-COLOR)))

; Signature: brick+scene: Brick Image -> Image
; Purpose: Add the Brick to the scene

(define (brick+scene sq scene)
  (place-image/cell (draw-brick sq)
                    (brick-x sq)
                    (brick-y sq)
                    scene))

(check-expect (brick+scene (make-brick 5 10 'green) BOARD)
              (place-image/cell O-BRICK-IMG
                                5 10
                                BOARD))
(check-expect (brick+scene (make-brick 6 9 'red) BOARD)
              (place-image/cell S-BRICK-IMG
                                6 9
                                BOARD))

; Signature: bricks+scene: Bricks Image -> Image
; Purpose: Adds all the Bricks to the scene

(define (bricks+scene bricks scene)
  (foldr brick+scene scene bricks))

(check-expect (bricks+scene '() BOARD) BOARD)
(check-expect (bricks+scene (list (make-brick 5 10 'green)) BOARD)
              (place-image/cell O-BRICK-IMG
                                5 10
                                BOARD))
(check-expect (bricks+scene (list (make-brick 5 11 'green) (make-brick 5 10 'green)) BOARD)
              (place-image/cell O-BRICK-IMG
                                5 10
                                (place-image/cell O-BRICK-IMG
                                                  5 11
                                                  BOARD)))

; Signature: tetra+scene: Tetra Image -> Image
; Purpose: Adds all the bricks in a tetra to the scene

(define (tetra+scene tetra scene)
  (foldr (lambda (curr scene-sofar)
           (brick+scene curr scene-sofar))
         scene (tetra-bricks tetra)))

(check-expect (tetra+scene (make-tetra (make-posn 3 4) '()) BOARD) BOARD)
(check-expect (tetra+scene O-TETRA BOARD)
              (brick+scene O-BRICK-1
                           (brick+scene O-BRICK-2
                                        (brick+scene O-BRICK-3
                                                     (brick+scene O-BRICK-4 BOARD)))))

;Signature: bricks-move: Bricks String -> Bricks
;Purpose: move each Brick in a Bricks 1 cell in given dir (left/right)

(define (bricks-move bricks dir)
  (map (lambda (curr-brick)
         (make-brick
          (if
           (string=? dir "left")
           (- (brick-x curr-brick) 1)
           (+ (brick-x curr-brick) 1)) ;move right
          (brick-y curr-brick)
          (brick-color curr-brick)))
       bricks))

(check-expect (bricks-move '() "left") '()) 
(check-expect (bricks-move (list (make-brick 5 10 'pink)) "left") (list (make-brick 4 10 'pink))) 
(check-expect (bricks-move (list (make-brick 5 10 'pink)) "right") (list (make-brick 6 10 'pink)))

;Signature: bricks-down: Bricks -> Bricks
;Purpose: move each Brick in a Bricks down 1 cell

(define (bricks-down bricks)
  (map (lambda (brick)
         (make-brick (brick-x brick) (- (brick-y brick) 1) (brick-color brick))) bricks))

(check-expect (bricks-down '()) '())
(check-expect (bricks-down (list (make-brick 5 10 'pink))) (list (make-brick 5 9 'pink)))
(check-expect (bricks-down O-BRICKS)
              (cons
               (make-brick 4 20 'green)
               (cons
                (make-brick 5 20 'green)
                (cons (make-brick 4 21 'green)
                      (cons (make-brick 5 21 'green) '())))))

;Signature: down-tetra: Tetra -> Tetra
;Purpose: Move tetra down one cell

(define (down-tetra tetra)
  (make-tetra (make-posn (posn-x (tetra-center tetra)) (- (posn-y (tetra-center tetra)) 1))
              (bricks-down (tetra-bricks tetra))))

(check-expect (down-tetra (make-tetra (make-posn 3 5) (list (make-brick 5 10 'pink))))
              (make-tetra (make-posn 3 4) (list (make-brick 5 9  'pink)))) ;; base: 1 brick in tetra
(check-expect (down-tetra O-TETRA)
              (make-tetra
               (make-posn 4.5 20.5)
               (cons
                (make-brick 4 20 'green)
                (cons
                 (make-brick 5 20 'green)
                 (cons (make-brick 4 21 'green)
                       (cons (make-brick 5 21 'green) '()))))))

;Signature: bricks-touch? Brick Bricks -> Boolean
;Purpose: Is Brick touching any of the Bricks? (same x coordinate, 1 greater y coordinate)

(define (bricks-touch? br brs)
  (ormap (lambda (brick-from-brs)
           (and
            (= (brick-y br) (+ (brick-y brick-from-brs) 1))
            (= (brick-x br) (brick-x brick-from-brs))))
         brs))

(check-expect (bricks-touch? (make-brick 4 0 'red)    '()) #f) ;touching floor but not a bricks
(check-expect (bricks-touch? (make-brick 5 2 'pink)   (tetra-bricks BOTTOM-TETRA)) #f)
(check-expect (bricks-touch? (make-brick 4 2 'purple) (tetra-bricks BOTTOM-TETRA)) #t)
(check-expect (bricks-touch? (make-brick 3 2 'orange) (tetra-bricks BOTTOM-TETRA)) #f)
              
;Signature: bottom-tetra? - Tetra -> Boolean
;Purpose: is the bottom of the tetra touching the bottom of the screen?

(define (bottom-tetra? tetra)
  (ormap (lambda (curr-brick)
           (= (brick-y curr-brick)  0))
         (tetra-bricks tetra)))

(check-expect (bottom-tetra?
               (make-tetra
                (make-posn 2 3) (cons (make-brick 4 0 'red) '()))) #t) ;base: one-brick tetra
(check-expect (bottom-tetra? O-TETRA)      #f)
(check-expect (bottom-tetra? BOTTOM-TETRA) #t)

;Signature: landed-tetra? - World -> Boolean
;Purpose: is the Tetra landed on the Pile?

(define (landed-tetra? world)
  (ormap (lambda (brick-from-tetra)
           (bricks-touch? brick-from-tetra (world-pile world)))
         (tetra-bricks (world-tetra world))))

(check-expect (landed-tetra? (make-world BOTTOM-TETRA '())) #f) ; @ bottom, but not touching a tetra
(check-expect (landed-tetra? (make-world O-TETRA (tetra-bricks BOTTOM-TETRA))) #f)
(check-expect (landed-tetra? (make-world LANDED-TETRA (tetra-bricks BOTTOM-TETRA))) #t)

;Signature: random-tetra: Number -> Tetra
;Purpose: Produce a new random Tetra from n given options

(define (random-tetra n)
  (cond [(= n 0) O-TETRA]
        [(= n 1) I-TETRA]
        [(= n 2) L-TETRA]
        [(= n 3) J-TETRA]
        [(= n 4) T-TETRA]
        [(= n 5) Z-TETRA]
        [else S-TETRA]))

(check-expect (random-tetra 0) O-TETRA)
(check-expect (random-tetra 1) I-TETRA)
(check-expect (random-tetra 2) L-TETRA)
(check-expect (random-tetra 3) J-TETRA)
(check-expect (random-tetra 4) T-TETRA)
(check-expect (random-tetra 5) Z-TETRA)
(check-expect (random-tetra 6) S-TETRA)

;Signature: bricks->pile - Bricks Bricks -> Bricks
;Purpose: add the Bricks (in a Tetra) to the Pile

(define (bricks->pile bricks pile)
  (foldr (lambda (curr-tetra-br pile-sofar)
           (cons curr-tetra-br pile-sofar))
         pile bricks))
 
(check-expect (bricks->pile '() (tetra-bricks BOTTOM-TETRA)) (tetra-bricks BOTTOM-TETRA))
(check-expect (bricks->pile (tetra-bricks BOTTOM-TETRA) '())
              (tetra-bricks BOTTOM-TETRA))
(check-expect (bricks->pile (tetra-bricks LANDED-TETRA) (tetra-bricks BOTTOM-TETRA))
              (cons (make-brick 3 2 'pink)
                    (cons (make-brick 4 2 'green)
                          (cons (make-brick 5 2 'red)
                                (cons (make-brick 4 0 'blue)
                                      (cons (make-brick 4 1 'orange) '()))))))               

;Signature: tetra->pile: World -> World
;Purpose: add a Tetra to a Pile

(define (tetra->pile world)
  (make-world
   (random-tetra (random 7))
   (bricks->pile (tetra-bricks (world-tetra world)) (world-pile world))))

(check-random (tetra->pile (make-world BOTTOM-TETRA '()))
              (make-world (random-tetra (random 7)) (tetra-bricks BOTTOM-TETRA)))
(check-random (tetra->pile (make-world LANDED-TETRA (tetra-bricks BOTTOM-TETRA)))
              (make-world (random-tetra (random 7))
                          (cons (make-brick 3 2 'pink)
                                (cons (make-brick 4 2 'green)
                                      (cons (make-brick 5 2 'red)
                                            (tetra-bricks BOTTOM-TETRA))))))

;Signature: next-world: World -> World
;Purpose: Move tetra down one cell. Stops at bottom/pile.

(define (next-world w)
  (cond [(or (bottom-tetra? (world-tetra w))
             (landed-tetra?  w))
         (tetra->pile w)]
        [else (make-world (down-tetra (world-tetra w))
                          (world-pile w))]))

(check-random (next-world (make-world O-TETRA '()))
              (make-world (down-tetra O-TETRA) '())) ;tetra not landed or bottom
(check-random (next-world (make-world BOTTOM-TETRA '())) ;tetra bottom
              (make-world (random-tetra (random 7)) (tetra-bricks BOTTOM-TETRA)))
(check-random (next-world (make-world LANDED-TETRA (tetra-bricks BOTTOM-TETRA))) ;tetra landed
              (make-world (random-tetra (random 7))
                          (cons (make-brick 3 2 'pink)
                                (cons (make-brick 4 2 'green)
                                      (cons (make-brick 5 2 'red)
                                            (cons (make-brick 4 0 'blue)
                                                  (cons (make-brick 4 1 'orange)
                                                        '())))))))

;Signature: move-tetra: Tetra String -> Tetra
;Purpose: Move tetra left or right one cell, based on given direction

(define (move-tetra tetra dir)
  (if (string=? "left" dir)
      (make-tetra (make-posn (- (posn-x (tetra-center tetra)) 1) (posn-y (tetra-center tetra)))
                  (bricks-move (tetra-bricks tetra) "left"))
      (make-tetra (make-posn (+ (posn-x (tetra-center tetra)) 1) (posn-y (tetra-center tetra)))
                  (bricks-move (tetra-bricks tetra) "right")))) ;moving to the right

(check-expect (move-tetra (make-tetra (make-posn 3 5) (list (make-brick 5 10 'pink))) "left")
              (make-tetra (make-posn 2 5) (list (make-brick 4 10  'pink)))) ;;base: 1 brick in tetra

(check-expect (move-tetra O-TETRA "left")
              (make-tetra (make-posn 3.5 21.5)
                          (cons
                           (make-brick 3 21 'green)
                           (cons
                            (make-brick 4 21 'green)
                            (cons (make-brick 3 22 'green)
                                  (cons (make-brick 4 22 'green) '()))))))

(check-expect (move-tetra O-TETRA "right")
              (make-tetra (make-posn 5.5 21.5)
                          (cons
                           (make-brick 5 21 'green)
                           (cons
                            (make-brick 6 21 'green)
                            (cons (make-brick 5 22 'green)
                                  (cons (make-brick 6 22 'green) '()))))))

;; Signature: brick-rotate-ccw : Brick Pt -> Brick
;; Rotate the brick 90 degrees counterclockwise around the posn.

(define (brick-rotate-ccw brick pt)
  (make-brick (+ (posn-x pt)
                 (- (posn-y pt)
                    (brick-y brick)))
              (+ (posn-y pt)
                 (- (brick-x brick)
                    (posn-x pt)))
              (brick-color brick)))

(check-expect (brick-rotate-ccw O-BRICK-1 O-PT) (make-brick 5 21 O-COLOR))
(check-expect (brick-rotate-ccw S-BRICK-1 S-PT) (make-brick 5 20 S-COLOR))

;; bricks-rotate-ccw : Bricks Pt -> Bricks
;; Rotate each Brick in a Bricks 90 degrees counterclockwise around the posn.

(define (bricks-rotate-ccw bricks pt)
  (map (lambda (curr-brick) (brick-rotate-ccw curr-brick pt)) bricks))

(check-expect (bricks-rotate-ccw '()      O-PT) '())
(check-expect (bricks-rotate-ccw O-BRICKS O-PT)
              (cons
               (make-brick 5 21 'green)
               (cons (make-brick 5 22 'green)
                     (cons (make-brick 4 21 'green)
                           (cons (make-brick 4 22 'green) '()))))) 

;; tetra-rotate-ccw : Tetra -> Tetra
;; Rotate a Tetra 90 degrees counterclockwise around the posn.

(define (tetra-rotate-ccw tetra)
  (make-tetra (tetra-center tetra) 
              (bricks-rotate-ccw (tetra-bricks tetra) (tetra-center tetra))))

(check-expect (tetra-rotate-ccw O-TETRA)
              (make-tetra O-PT
                          (cons
                           (make-brick 5 21 'green)
                           (cons (make-brick 5 22 'green)
                                 (cons (make-brick 4 21 'green)
                                       (cons (make-brick 4 22 'green) '()))))))
(check-expect (tetra-rotate-ccw S-TETRA)
              (make-tetra S-PT
                          (cons
                           (make-brick 5 20 'red)
                           (cons (make-brick 5 21 'red)
                                 (cons (make-brick 4 21 'red)
                                       (cons (make-brick 4 22 'red) '()))))))

;; tetra-rotate-cw : Tetra -> Tetra
;; Rotate a Tetra 90 degrees clockwise around the posn.

(define (tetra-rotate-cw tetra)
  (tetra-rotate-ccw (tetra-rotate-ccw (tetra-rotate-ccw tetra))))

(check-expect (tetra-rotate-cw O-TETRA)
              (make-tetra O-PT
                          (cons (make-brick 4 22 'green)
                                (cons (make-brick 4 21 'green)
                                      (cons (make-brick 5 22 'green)
                                            (cons (make-brick 5 21 'green) '()))))))
(check-expect (tetra-rotate-cw S-TETRA)
              (make-tetra S-PT
                          (cons (make-brick 4 23 'red)
                                (cons (make-brick 4 22 'red)
                                      (cons (make-brick 5 22 'red)
                                            (cons (make-brick 5 21 'red) '()))))))

;Signature - pile-contains? Tetra Bricks -> Boolean
;Purpose - Does the pile contain any of the Bricks of Tetra?

(define (pile-contains? tetra pile)
  (local [(define (contains? brick bricks) ;Is this Brick within Bricks(just x & y value, not color)?
            (ormap (lambda (curr-brick)
                     (and (= (brick-x curr-brick) (brick-x brick))
                          (= (brick-y curr-brick) (brick-y brick))))
                   bricks))]
    (ormap (lambda (curr-tetra-brick)
             (contains? curr-tetra-brick pile))

           (tetra-bricks tetra))))

(check-expect (pile-contains? (make-tetra (make-posn 4 2) (list (make-brick 4 0 'blue))) '()) #f)
(check-expect (pile-contains? (make-tetra (make-posn 4 1)
                                          (cons (make-brick 4 1 'blue)
                                                (cons (make-brick 4 2 'blue) '())))
                              (cons (make-brick 4 3 'blue)
                                    (cons (make-brick 4 0 'blue)
                                          (cons (make-brick 4 1 'orange) '())))) #t)
(check-expect (pile-contains? (make-tetra (make-posn 4 1) (list (make-brick 4 1 'blue)))
                              (cons (make-brick 4 0 'blue) (cons (make-brick 4 1 'orange) '()))) #t)

(check-expect (pile-contains? (make-tetra (make-posn 4 5) (list (make-brick 4 6 'blue)))
                              (cons (make-brick 4 0 'blue) (cons (make-brick 4 1 'orange) '()))) #f)


;Signature - collide-left?: World -> Boolean
;Purpose - Will the tetra collide with bricks in pile (horizontally) to the left?

(define (collide-left? world)
  (pile-contains? (move-tetra (world-tetra world) "left") (world-pile world)))

(check-expect (collide-left? (make-world (make-tetra (make-posn 5 1.5)
                                                     (cons (make-brick 5 1 'blue)
                                                           (cons (make-brick 5 2 'orange) '())))
                                         (tetra-bricks BOTTOM-TETRA))) #t)

(check-expect (collide-left? (make-world (make-tetra (make-posn 3 1.5)
                                                     (cons (make-brick 3 1 'blue)
                                                           (cons (make-brick 3 2 'orange) '())))
                                         (tetra-bricks BOTTOM-TETRA))) #f)

(check-expect (collide-left? (make-world (make-tetra (make-posn 5 1.5)
                                                     (cons (make-brick 5 1 'blue)
                                                           (cons (make-brick 5 2 'orange) '())))
                                         '())) #f) ; no bricks in pile

;Signature - collide-right?: World -> Boolean
;Purpose - Will the tetra collide with bricks in pile (horizontally) to the right?

(define (collide-right? world)
  (pile-contains? (move-tetra (world-tetra world) "right") (world-pile world)))

(check-expect (collide-right? (make-world (make-tetra (make-posn 3 1.5)
                                                      (cons (make-brick 3 1 'blue)
                                                            (cons (make-brick 3 2 'orange) '())))
                                          (tetra-bricks BOTTOM-TETRA))) #t)

(check-expect (collide-right? (make-world (make-tetra (make-posn 5 1.5)
                                                      (cons (make-brick 5 1 'blue)
                                                            (cons (make-brick 5 2 'orange) '())))
                                          (tetra-bricks BOTTOM-TETRA))) #f)

(check-expect (collide-right? (make-world (make-tetra (make-posn 5 1.5)
                                                      (cons (make-brick 5 1 'blue)
                                                            (cons (make-brick 5 2 'orange) '())))
                                          '())) #f) ; no bricks in pile

;Signature - off-screen?: Bricks String -> Boolean
;Purpose - Is the tetra off the given side of the screen (left, right, top)?
(define (off-screen? bricks dir)
  (ormap (lambda (curr-brick)
           (cond [(string=? dir "left")  (< (brick-x curr-brick)    0)]
                 [(string=? dir "right") (>= (brick-x curr-brick)  BOARD-WIDTH)]
                 [(string=? dir "top")   (>= (brick-y curr-brick) BOARD-HEIGHT)]))
         bricks))

(check-expect (off-screen? (tetra-bricks (tetra-rotate-ccw ONE-BRICK)) "left")        #f)
(check-expect (off-screen? (tetra-bricks (tetra-rotate-ccw LEFT-EDGE-TETRA)) "left")  #t)
(check-expect (off-screen? (tetra-bricks (tetra-rotate-ccw RIGHT-EDGE-TETRA)) "left") #f)
(check-expect (off-screen? (tetra-bricks(tetra-rotate-ccw LEFT-EDGE-TETRA))  "right")  #f)
(check-expect (off-screen? (tetra-bricks (tetra-rotate-ccw RIGHT-EDGE-TETRA)) "right")  #t)
(check-expect (off-screen? '()                             "top") #f)
(check-expect (off-screen? (tetra-bricks O-TETRA)          "top") #t)

; Signature: move-off?: Tetra KE Num Num -> Boolean
; Purpose: Will moving tetra left/right or rotating tetra ccw/cw cause it to go off the scene?

(define (move-off? tetra ke)
  (cond [(string=? ke "left")  (off-screen? (tetra-bricks (move-tetra       tetra "left")) "left")]
        [(string=? ke "right") (off-screen? (tetra-bricks (move-tetra       tetra "right")) "right")]
        [(string=? ke "a")     (or
                                (off-screen? (tetra-bricks (tetra-rotate-ccw tetra)) "left")
                                (off-screen? (tetra-bricks (tetra-rotate-ccw tetra)) "right"))]
        [(string=? ke "s")     (or
                                (off-screen? (tetra-bricks (tetra-rotate-cw tetra)) "left")
                                (off-screen? (tetra-bricks (tetra-rotate-cw tetra)) "right"))]))

(check-expect (move-off? LEFT-EDGE-TETRA  "left")  #t)
(check-expect (move-off? LEFT-EDGE-TETRA  "right")  #f)
(check-expect (move-off? RIGHT-EDGE-TETRA "right")  #t)
(check-expect (move-off? RIGHT-EDGE-TETRA "left")  #f)
(check-expect (move-off? RIGHT-EDGE-TETRA "a")  #t)
(check-expect (move-off? RIGHT-EDGE-TETRA "s")  #t)

;Signature - game-end?: World -> Boolean
;Purpose - is the World in an end state? (pile: off-screen? -> #t)

(define (game-end? w)
  (off-screen? (world-pile w) "top"))

(check-expect (game-end? (make-world LEFT-EDGE-TETRA (tetra-bricks O-TETRA)))      #t)
(check-expect (game-end? (make-world O-TETRA         (tetra-bricks BOTTOM-TETRA))) #f)

;Signature - num-bricks-off: Bricks Num -> Number
;Purpose - count the number of Bricks off top of screen (when Tetra lands on Pile)

(define (num-bricks-off pile bheight)
  (foldr (lambda (curr-brick sofar)
           (if
            (>= (brick-y curr-brick) bheight)
            (+ 1 sofar)
            sofar))
         0 pile))

(check-expect (num-bricks-off '()                                              BOARD-HEIGHT) 0)
(check-expect (num-bricks-off (tetra-bricks (down-tetra (down-tetra O-TETRA))) BOARD-HEIGHT) 2)
(check-expect (num-bricks-off (tetra-bricks O-TETRA)                           BOARD-HEIGHT) 4)

;Signature - fix-rotation: Tetra Num Num -> Tetra
;Purpose - move tetra that would have rotated off the screen to valid position

(define (fix-rotation tetra bheight bwidth)
  (if (not
       (or
        (off-screen? (tetra-bricks tetra) "left")
        (off-screen? (tetra-bricks tetra) "right")))    ; rotation doesn't put tetra off screen
      tetra                                             ; regular rotated tetra
      (cond [(off-screen? (tetra-bricks tetra) "left")  ; rotation puts tetra off to the left
             (if (not (off-screen? (tetra-bricks (move-tetra tetra "right")) "left"))
                 (move-tetra tetra "right")             ; will moving right put it back on the screen?
                 (fix-rotation (move-tetra tetra "right") bheight bwidth))]
            [(off-screen? (tetra-bricks tetra) "right") ; rotation puts tetra off to the right
             (if (not (off-screen? (tetra-bricks (move-tetra tetra "left")) "right")) 
                 (move-tetra tetra "left")              ; will moving left put it back on the screen?
                 (fix-rotation (move-tetra tetra "left") bheight bwidth))])))

(check-expect (fix-rotation CW-ROTATED-LEFT-EDGE BOARD-HEIGHT BOARD-WIDTH)
              CW-ROTATED-LEFT-EDGE) ;return tetra because rotation doesn't put tetra off screen

(check-expect (fix-rotation OFFLEFT2 BOARD-HEIGHT BOARD-WIDTH)
              (make-tetra (make-posn 0.5 5.5)
                          (cons (make-brick 0 5 'red)
                                (cons (make-brick 0 6 'red) '()))))

(check-expect (fix-rotation OFFLEFT BOARD-HEIGHT BOARD-WIDTH)
              (make-tetra (make-posn 0.5 12.5)
                          (cons (make-brick 0 12 'purple)
                                (cons (make-brick 1 12 'purple)
                                      (cons (make-brick 0 13 'purple)
                                            (cons (make-brick 0 14 'purple) '()))))))
              
(check-expect (fix-rotation CCW-ROTATED-RIGHT-EDGE BOARD-HEIGHT BOARD-WIDTH)
              (make-tetra (make-posn 8.5 12.5)
                          (cons (make-brick 9 12 'cyan)
                                (cons (make-brick 9 11 'cyan)
                                      (cons (make-brick 8 12 'cyan)
                                            (cons (make-brick 7 12 'cyan) '()))))))

;Signature: final-score: World Number Number -> Number
;Purpose: Final score, calculated by # of bricks visible on screen given height

(define (final-score world bheight)
  (foldr (lambda (curr-brick sofar)
           (if (< (brick-y curr-brick) bheight)
               (+ 1 sofar)
               sofar))
         0 (world-pile world)))

(check-expect (final-score (make-world O-TETRA
                                       (cons (make-brick 3 2 'pink)
                                             (cons (make-brick 4 2 'green)
                                                   (cons (make-brick 5 2 'red)
                                                         (cons (make-brick 4 0 'blue)
                                                               (cons (make-brick 4 1 'orange)
                                                                     '())))))) BOARD-HEIGHT) 5)

(check-expect (final-score (make-world O-TETRA (cons (make-brick 3 19 'pink)
                                                     (cons (make-brick 4 20 'green)
                                                           '()))) BOARD-HEIGHT) 1)

(check-expect (final-score (make-world O-TETRA '()) BOARD-HEIGHT) 0)

;Signature - num->img: Number -> Image
;Purpose - render a Number to an image

(define (num->img n)
  (text (number->string n) 20 'blue))
  
(check-expect (num->img 3) (text "3" 20 'blue))
(check-expect (num->img 4) (text "4" 20 'blue))

;Signature - score->screen Number Image -> Image
;Purpose - renders an Image of the score onto the Board

(define (score->scene n scene)
  (place-image/cell (num->img n) .5 (- BOARD-HEIGHT 1.5) scene))

(check-expect (score->scene 12 BOARD) (place-image/cell (num->img 12) .5 18.5 BOARD))
(check-expect (score->scene 40 BOARD) (place-image/cell (num->img 40) .5 18.5 BOARD))

;;; world->scene : World -> Image
;;; Render the given world into an image

(define (world->scene w)
  (score->scene (final-score w BOARD-HEIGHT)
                (tetra+scene (world-tetra w) (bricks+scene (world-pile w) BOARD))))

(check-expect (world->scene (make-world O-TETRA '()))
              (score->scene 0 BOARD))
(check-expect (world->scene (make-world LANDED-TETRA (tetra-bricks BOTTOM-TETRA)))
              (score->scene 2
                            (tetra+scene LANDED-TETRA
                                         (bricks+scene (tetra-bricks BOTTOM-TETRA)
                                                       BOARD))))

;Signature - key-handler: World KE -> World
;Purpose - shift or rotate Tetra based on key input
(define (key-handler w ke)
  (cond
    [(key=? ke "a") (cond [(or
                            (off-screen?
                             (tetra-bricks (tetra-rotate-ccw (world-tetra w))) "left")
                            (off-screen?
                             (tetra-bricks (tetra-rotate-ccw (world-tetra w))) "right"))
                           (make-world (fix-rotation (tetra-rotate-ccw (world-tetra w))
                                                     BOARD-HEIGHT BOARD-WIDTH) (world-pile w))]   
                          [(pile-contains? (tetra-rotate-ccw (world-tetra w)) (world-pile w)) w]
                          [else (make-world (tetra-rotate-ccw (world-tetra w)) (world-pile w))])]

    [(key=? ke "s") (cond [(or
                            (off-screen?
                             (tetra-bricks (tetra-rotate-cw (world-tetra w))) "left")
                            (off-screen?
                             (tetra-bricks (tetra-rotate-cw (world-tetra w))) "right"))
                           (make-world (fix-rotation (tetra-rotate-cw (world-tetra w))
                                                     BOARD-HEIGHT BOARD-WIDTH) (world-pile w))]
                          [(pile-contains? (tetra-rotate-cw (world-tetra w)) (world-pile w)) w]
                          [else (make-world (tetra-rotate-cw (world-tetra w)) (world-pile w))])]
    
    [(key=? ke "left") (if (or (collide-left? w)   ; collide or bump into pile
                               (move-off? (world-tetra w) ke))
                           w  ; keep same world
                           (make-world (move-tetra (world-tetra w) "left") (world-pile w)))]
    
    [(key=? ke "right") (if (or (collide-right? w) ; collide or bump into pile
                                (move-off? (world-tetra w) ke))
                            w ; keep same world
                            (make-world (move-tetra (world-tetra w) "right") (world-pile w)))]
    [else w])) ; keep same world

(check-expect (key-handler (make-world S-TETRA '()) "a")
              (make-world (tetra-rotate-ccw S-TETRA) '()))
(check-expect (key-handler (make-world CCW-ROTATED-RIGHT-EDGE '()) "a")
              (make-world (fix-rotation (tetra-rotate-ccw CCW-ROTATED-RIGHT-EDGE)
                                        BOARD-HEIGHT BOARD-WIDTH) '()))

(check-expect (key-handler (make-world S-TETRA '()) "s")
              (make-world (tetra-rotate-cw  S-TETRA) '()))
(check-expect (key-handler (make-world CW-ROTATED-RIGHT-EDGE '()) "s")
              (make-world (fix-rotation (tetra-rotate-cw CW-ROTATED-RIGHT-EDGE)
                                        BOARD-HEIGHT BOARD-WIDTH) '()))

(check-expect (key-handler (make-world S-TETRA '()) "right")
              (make-world (move-tetra      S-TETRA "right") '()))
(check-expect (key-handler (make-world ONE-BRICK (cons (make-brick 13 14 'red) '())) "right")
              (make-world ONE-BRICK (cons (make-brick 13 14 'red) '())))

(check-expect (key-handler (make-world S-TETRA '()) "left")
              (make-world (move-tetra       S-TETRA "left") '()))
(check-expect (key-handler (make-world ONE-BRICK (tetra-bricks OFFRIGHT)) "left")
              (make-world ONE-BRICK (tetra-bricks OFFRIGHT)))

(check-expect (key-handler (make-world S-TETRA '()) "h")
              (make-world                   S-TETRA '()))

;Signature - final-screen: World -> Image
;Purpose - renders an image of your final score

(define (final-screen w)
  (score->scene (final-score w BOARD-HEIGHT)
                (tetra+scene (world-tetra w) (bricks+scene (world-pile w) BOARD))))

(check-expect (final-screen (make-world LANDED-TETRA '()))
              (score->scene 0 (tetra+scene LANDED-TETRA BOARD)))
(check-expect (final-screen (make-world O-TETRA (tetra-bricks BOTTOM-TETRA)))
              (score->scene 2 (tetra+scene O-TETRA
                                           (bricks+scene (tetra-bricks BOTTOM-TETRA)
                                                         BOARD))))

; - full-row? is the row complete and full
; - clear-row clear the full row
; - shift-pile shift the pile down when row is cleared

;;; A Row is a (make-row Number [Listof Bricks])

(define-struct row [rownum bricks])

;Signature - full-row?: World Number -> Boolean
;Purpose - Is given Row # a full row?

#|
;Signature - full-row?: World Number -> Boolean
;Purpose - Is given Row # a full row?

(define (full-row? world rownum)
  (= (length
      (filter (lambda (curr-brick)
                (= rownum (brick-y curr-brick))) (world-pile world)))
     10))

(check-expect (full-row? BOTT-ROW-WORLD 0)           #t)
(check-expect (full-row? BOTT/FIRST-ROW-WORLD 3)     #f)
(check-expect (full-row? (make-world S-TETRA '()) 4) #f) |#

;NumSet Number -> Boolean
; Is the number a member of the set?
(define (contains? s n)
  (ormap (lambda (elt) (= elt n)) s))


(check-expect (contains? '() 8)          #f)
(check-expect (contains? (list 1 2 3) 1) #t)
(check-expect (contains? (list 1 2 3) 4) #f)

;Signature - pile->rows: World -> [Listof Rows]
;Purpose - splits a pile into a List of its Rows
(define (pile->rows world)
  (local [(define rows-with-bricks
            (foldr (lambda (curr-brick list-rows) (if (contains? list-rows (brick-y curr-brick))
                                                      list-rows
                                                      (cons (brick-y curr-brick) list-rows)))
                   '()
                   (world-pile world)))]
    (map (lambda (curr-row) (make-row
                             curr-row
                             (filter (lambda (curr-brick) ; list of bricks with a certain y value
                                       (= (brick-y curr-brick) curr-row))
                                     (world-pile world))))
         rows-with-bricks)))

; look at these tests, add test with random tetra
(check-expect (pile->rows BOTT-ROW-WORLD)
              (list (make-row
                     0
                     (list
                      (make-brick 0 0 "goldenrod")
                      (make-brick 1 0 "goldenrod")
                      (make-brick 2 0 "goldenrod")
                      (make-brick 3 0 "goldenrod")
                      (make-brick 4 0 "goldenrod")
                      (make-brick 5 0 "goldenrod")
                      (make-brick 6 0 "goldenrod")
                      (make-brick 7 0 "goldenrod")
                      (make-brick 8 0 "goldenrod")
                      (make-brick 9 0 "goldenrod")))))
(check-expect (pile->rows BOTT/FIRST-ROW-WORLD)
              (list (make-row
                     0
                     (list
                      (make-brick 0 0 "goldenrod")
                      (make-brick 1 0 "goldenrod")
                      (make-brick 2 0 "goldenrod")
                      (make-brick 3 0 "goldenrod")
                      (make-brick 4 0 "goldenrod")
                      (make-brick 5 0 "goldenrod")
                      (make-brick 6 0 "goldenrod")
                      (make-brick 7 0 "goldenrod")
                      (make-brick 8 0 "goldenrod")
                      (make-brick 9 0 "goldenrod")))
                    (make-row
                     1
                     (list
                      (make-brick 0 1 "purple")
                      (make-brick 1 1 "purple")
                      (make-brick 2 1 "purple")
                      (make-brick 3 1 "purple")
                      (make-brick 4 1 "purple")
                      (make-brick 5 1 "purple")
                      (make-brick 6 1 "purple")
                      (make-brick 7 1 "purple")
                      (make-brick 8 1 "purple")
                      (make-brick 9 1 "purple")))))

;Signature - full-rows: World -> [Listof Numbers]
;Purpose - returns list of full rows in World

(define (full-rows world)
  (foldr (lambda (curr-row full-rows) (if (= 10 (length (row-bricks curr-row)))
                                          (cons (row-rownum curr-row) full-rows)
                                          full-rows))
         '() (pile->rows world)))

(check-expect (full-rows BOTT-ROW-WORLD)          '(0))
(check-expect (full-rows BOTT/FIRST-ROW-WORLD)    '(0 1))
(check-expect (full-rows (make-world S-TETRA '())) '())
(check-expect (full-rows (make-world S-TETRA (list (make-brick 3 4 "pink")))) '())

;Signature - rows->pile: [Listof Rows] -> [Listof Bricks]
;Purpose - convert list of Rows to list of Bricks (pile)

(define (rows->pile rows)
  (foldr (lambda (curr-row pile-so-far)
           (append (row-bricks curr-row) pile-so-far))
         '() rows))

(check-expect (rows->pile '()) '())
(check-expect (rows->pile (list (make-row
                                 0
                                 (list
                                  (make-brick 0 0 "goldenrod")
                                  (make-brick 1 0 "goldenrod")
                                  (make-brick 2 0 "goldenrod")
                                  (make-brick 3 0 "goldenrod")
                                  (make-brick 4 0 "goldenrod")
                                  (make-brick 5 0 "goldenrod")
                                  (make-brick 6 0 "goldenrod")
                                  (make-brick 7 0 "goldenrod")
                                  (make-brick 8 0 "goldenrod")
                                  (make-brick 9 0 "goldenrod")))
                                (make-row
                                 1
                                 (list
                                  (make-brick 0 1 "purple")
                                  (make-brick 1 1 "purple")
                                  (make-brick 2 1 "purple")
                                  (make-brick 3 1 "purple")
                                  (make-brick 4 1 "purple")
                                  (make-brick 5 1 "purple")
                                  (make-brick 6 1 "purple")
                                  (make-brick 7 1 "purple")
                                  (make-brick 8 1 "purple")
                                  (make-brick 9 1 "purple")))))
              (world-pile BOTT/FIRST-ROW-WORLD))

;Signature - clear-row: World -> World
;Purpose - if a Row is full, clear it

(define ROW-NUM-LIST '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19))

(define (clear-row world)
  (make-world (world-tetra world)
              (rows->pile
               (filter (lambda (curr-row)
                         (not (= (length (row-bricks curr-row)) 10)))
                       (pile->rows world)))))

(check-expect (clear-row BOTT-ROW-WORLD) (make-world O-TETRA '()))
(check-expect (clear-row BOTT/FIRST-ROW-WORLD) (make-world S-TETRA '()))
(check-expect (clear-row (make-world S-TETRA (cons (make-brick 0 3 "pink") FULL-ROW-Y=0&1)))
              (make-world S-TETRA (cons (make-brick 0 3 "pink") '())))

;Signature - num-clearable-rows: Number [Listof Numbers] ;full-rows output -> NatNumber
;Purpose - number of clearable rows below given row #

(define (num-clearable-rows num row-nums)
  (foldr (lambda (curr-num amount-below)
           (if
            (< curr-num num)
            (+ 1 amount-below)
            amount-below)) 0 row-nums))

(check-expect (num-clearable-rows 6 '())          0)
(check-expect (num-clearable-rows 2 '(5 6 7))     0)
(check-expect (num-clearable-rows 3 '(1 2 3 4 5)) 2)

;Signature - shift-pile: World -> World
;Purpose - shift pile into place after clearing rows (anything that can move down will)

(define (shift-pile world)
  (local [(define num-cleared-rows
            (- (length (pile->rows world)) (length (pile->rows (clear-row world)))))
          (define tot-cleared-rows
            (full-rows world))]
    (clear-row
     (make-world (world-tetra world)
                (rows->pile
                 (foldr (lambda (curr-row rows-so-far)
                          (local [(define cleared-below-num
                                    (num-clearable-rows (row-rownum curr-row) tot-cleared-rows))]
                            (make-row
                             (- (row-rownum curr-row) cleared-below-num)
                          (map (lambda (curr-brick)
                                 (make-brick
                                  (brick-x curr-brick)
                                  (- (brick-y curr-brick)
                                     cleared-below-num)
                                  (brick-color curr-brick))) (row-bricks curr-row)))))
                        '() (pile->rows world)))))))

(define TICK-RATE .1) ; seconds
(big-bang (make-world (random-tetra (random 7)) '())
  [on-tick next-world TICK-RATE]
  [to-draw world->scene]
  [on-key key-handler]
  [stop-when game-end? final-screen])


