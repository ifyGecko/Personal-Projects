(ql:quickload "lisp-unit")

(load "~/OrbWeaver/OrbWeaver.lisp")


;;;algebraic operator tests
(lisp-unit::define-test + (lisp-unit::assert-equal 1 (derivative '(+ 3 x) 'x)))

(lisp-unit::define-test - (lisp-unit::assert-equal 0 (derivative '(- 3 (+ 4 5)) 'x)))

(lisp-unit::define-test * (lisp-unit::assert-equal 3 (derivative '(* 3 x) 'x)))
	    
(lisp-unit::define-test / (lisp-unit::assert-equal '() (derivative '(/ (2x+1) x) 'x)));broken
	    
(lisp-unit::define-test expt (lisp-unit::assert-equal '(* 2 x) (derivative '(expt x 2) 'x)))

(lisp-unit::define-test log (lisp-unit::assert-equal '(/ 1 (* x (ln 10))) (derivative '(log x 10) 'x)))

(lisp-unit::define-test ln (lisp-unit::assert-equal '(/ 1 x) (derivative '(ln x) 'x)))


;;;trig tests
(lisp-unit::define-test sin (lisp-unit::assert-equal '(cos x) (derivative '(sin x) 'x)))

(lisp-unit::define-test cos (lisp-unit::assert-equal '(* -1 (sin x)) (derivative '(cos x) 'x)))

(lisp-unit::define-test tan (lisp-unit::assert-equal '(expt (sec x) 2) (derivative '(tan x) 'x)))

(lisp-unit::define-test sec (lisp-unit::assert-equal '(* (sec x) (tan x)) (derivative '(sec x) 'x)))

(lisp-unit::define-test csc (lisp-unit::assert-equal '(* -1 (* (csc x) (cot x))) (derivative '(csc x) 'x)))

(lisp-unit::define-test cot (lisp-unit::assert-equal '(* -1 (expt (csc x) 2)) (derivative '(cot x) 'x)))

(lisp-unit::define-test asin (lisp-unit::assert-equal '(/ 1 (SQRT (+ 1 (EXPT X 2)))) (derivative '(asin x) 'x)))

(lisp-unit::define-test acos (lisp-unit::assert-equal '(* -1 (/ 1 (SQRT (+ 1 (expt x 2))))) (derivative '(acos x) 'x)))

(lisp-unit::define-test atan (lisp-unit::assert-equal '(/ 1 (+ 1 (EXPT X 2))) (derivative '(atan x) 'x)))

(lisp-unit::define-test asec (lisp-unit::assert-equal '(/ 1 (* (ABS X) (SQRT (- (EXPT X 2) 1)))) (derivative '(asec x) 'x)))
			      
(lisp-unit::define-test acsc (lisp-unit::assert-equal '(* -1 (/ 1 (* X (SQRT (- (EXPT X 2) 1))))) (derivative '(acsc x) 'x)))

(lisp-unit::define-test acot (lisp-unit::assert-equal '(* -1 (/ 1 (+ 1 (EXPT X 2)))) (derivative '(acot x) 'x)))

;;;hyperbolic trig tests


;;run all tests
(lisp-unit::run-tests :all)
