
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : maxima-menus.scm
;; DESCRIPTION : Menus for the maxima plugin
;; COPYRIGHT   : (C) 2005  Joris van der Hoeven
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (maxima-menus)
  (:use (utils plugins plugin-cmd)
	(doc help-funcs)
	(dynamic scripts-edit)
	(convert tools tmconcat)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Several subroutines for the evaluation of Maxima expressions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (maxima-prompt? t)
  (match? t '(with "mode" "text" "font-family" "tt" "color" "red" :*)))

(define (maxima-output-simplify t)
  ;;(display* "Simplify " t "\n")
  (cond ((and (func? t 'concat) (> (length t) 2) (maxima-prompt? (cadr t)))
	 (plugin-output-std-simplify "maxima" (cons 'concat (cddr t))))
	((match? t '(with "mode" "math" "math-display" "true" :%1))
	 `(math ,(maxima-output-simplify (cAr t))))
	((func? t 'with 1)
	 (maxima-output-simplify (cAr t)))
	((func? t 'with)
	 (append (cDr t) (maxima-output-simplify (cAr t))))
	((func? t 'concat)
	 (apply tmconcat (map maxima-output-simplify (cdr t))))
	(else (plugin-output-std-simplify "maxima" t))))

(define (maxima-contains-prompt? t)
  (cond ((maxima-prompt? t) #t)
	((func? t 'concat)
	 (list-or (map maxima-contains-prompt? (cdr t))))
	((and (func? t 'with) (nnull? (cdr t)))
	 (maxima-contains-prompt? (cAr t)))
	(else #f)))

(tm-define (plugin-output-simplify name t)
  (:require (== name "maxima"))
  ;;(display* "Simplify output " t "\n")
  (if (func? t 'document)
      (with u (list-find (cdr t) maxima-contains-prompt?)
	(if u (maxima-output-simplify u) ""))
      (maxima-output-simplify t)))

(define maxima-apply script-apply)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The Maxima menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind maxima-menu
  (if (not-in-session?)
      (link scripts-eval-menu)
      ---)
  (-> "Simplification"
      ("Simplify" (maxima-apply "fullratsimp"))
      ("Factor" (maxima-apply "factor"))
      ("Expand" (maxima-apply "expand"))
      ("Expand#w.r.t." (maxima-apply "expandwrt" 2)))
  (-> "Solving equations"
      ("Solve" (maxima-apply "solve"))
      ("Solve in" (maxima-apply "solve" 2)))
  (-> "Arithmetic"
      ("Factor" (maxima-apply "factor"))
      ("Gcd" (maxima-apply "gcd"))
      ("Lcm" (maxima-apply "lcm")))
  (-> "Logarithms"
      ("Exponential" (maxima-apply "exp"))
      ("Logarithm" (maxima-apply "log"))
      ("Square root" (maxima-apply "sqrt"))
      ---
      ("Contract logarithms" (maxima-apply "logcontract"))
      ("Expand logarithms" (maxima-apply "logexpand")))
  (-> "Trigonometry"
      ("Cosine" (maxima-apply "cos"))
      ("Sine" (maxima-apply "sin"))
      ("Tangent" (maxima-apply "tan"))
      ("Arc cosine" (maxima-apply "acos"))
      ("Arc sine" (maxima-apply "asin"))
      ("Arc tangent" (maxima-apply "atan"))
      ---
      ("Reduce trigonometric functions" (maxima-apply "trigreduce"))
      ("Reduce trigonometric functions#w.r.t." (maxima-apply "trigreduce" 2))
      ("Expand trigonometric functions" (maxima-apply "trigexpand")))
  (-> "Special functions"
      ("Airy" (maxima-apply "Airy"))
      ("Erf" (maxima-apply "erf"))
      ("Gamma" (maxima-apply "Gamma"))
      ("Psi" (maxima-apply "Psi")))
  (-> "Calculus"
      ("Differentiate" (maxima-apply "diff" 2))
      ("Integrate" (maxima-apply "integrate" 2)))
  (-> "Linear algebra"
      ("Determinant" (maxima-apply "determinant"))
      ("Echelon" (maxima-apply "echelon"))
      ("Eigenvalues" (maxima-apply "eigenvalues"))
      ("Invert" (maxima-apply "invert"))
      ("Rank" (maxima-apply "rank"))
      ("Transpose" (maxima-apply "transpose"))
      ("Triangularize" (maxima-apply "triangularize")))
  (if (not-in-session?)
      ---
      (link scripts-eval-toggle-menu)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional icons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind maxima-help-icons
  (if (and (in-maxima?) maxima-help)
      |
      ((balloon (icon "tm_help.xpm") "Maxima manual")
       (load-help-buffer maxima-help))))
