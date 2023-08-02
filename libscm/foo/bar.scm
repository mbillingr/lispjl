(define-library (foo bar)
    (export baz hi)
    (begin
      (define baz 123)
      (define (hi x) x)
      ))
