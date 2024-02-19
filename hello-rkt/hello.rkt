#lang racket

"Hello, racket!"
(newline)

(define (get-element-ll ll n)
  (if (>= n (length ll))
      "Invalid index"
      (if (= n 0)
          (car ll)
          (get-element-ll (cdr ll) (- n 1)))))

(define (make-matrix rows cols)
  (define vec (make-vector rows))
  (do ((i 0 (+ i 1)))
      ((= i rows) vec)
    (vector-set! vec i (make-vector cols 0))))

(define (matrix-set! matrix row col value)
  (vector-set! (vector-ref matrix row) col value))

(define (matrix-get matrix row col)
  (vector-ref (vector-ref matrix row) col))

(define (matrix-rows matrix)
  (vector-length matrix))

(define (matrix-cols matrix)
  (vector-length (vector-ref matrix 0)))

(define (construct-matrix rows)
  (make-matrix (length rows) (length (car rows)) rows))

(construct-matrix
 '('(1 2 3)
   '(4 5 6)
   '(7 8 9)))
