#lang racket
;; 
;; Author: beefy24 (https://github.com/beefy24), 2024.
;; 
;; ╔══════════════════════════════════════════════════════════════════════════════╗
;; ║ PROGRAM DESCRIPTION:                                                         ║
;; ║ • This is a simplified SQL SELECT query string validator.                    ║
;; ║ • Use it by calling the `validate` function followed by a string input.      ║
;; ║ • Example: `(validate "SELECT * FROM table ;")`                              ║
;; ║ • All symbols are separated by a blank space, columns by a comma.            ║
;; ║ • Column and table names can be surrounded by [] and "", respectively.       ║
;; ║ • More examples are shown at the end of this file.                           ║
;; ╚══════════════════════════════════════════════════════════════════════════════╝
;;

;;String library
(require racket/string)

;;A function alias
(define eq? equal?)

;;The list of all possible tokens/symbols.
(define tokens '("SELECT" "ALL" "DISTINCT" "DISTINCTROW" "*" "," "FROM" ";" "" null #\newline))

;; PARSE TABLE (REGULAR GRAMMAR):
;; ╔══════════╦═══╦════════╦══════════════╦════════╦════════════╦═══╦══════╦═══════════╦═════╗
;; ║ VARIABLE ║   ║ SELECT ║ ALL|DISTINCT ║ * FROM ║ ColumnName ║ , ║ FROM ║ TableName ║ ;ε  ║
;; ╠══════════╬═══╬════════╬══════════════╬════════╬════════════╬═══╬══════╬═══════════╬═════╣
;; ║ START->  ║   ║ A      ║              ║        ║            ║   ║      ║           ║     ║
;; ║ A ->     ║ B ║        ║ B            ║        ║            ║   ║      ║           ║     ║
;; ║ B ->     ║ C ║        ║              ║ E      ║            ║   ║      ║           ║     ║
;; ║ C ->     ║   ║        ║              ║        ║ D          ║   ║      ║           ║     ║
;; ║ D ->     ║   ║        ║              ║        ║            ║ C ║ E    ║           ║     ║
;; ║ E ->     ║   ║        ║              ║        ║            ║   ║      ║ F         ║     ║
;; ║ F ->     ║   ║        ║              ║        ║            ║   ║      ║           ║ END ║
;; ╚══════════╩═══╩════════╩══════════════╩════════╩════════════╩═══╩══════╩═══════════╩═════╝
;; Note: The 2nd unnamed column is a default rule, which is applied when no other rules match the input symbol.


;;The main function which checks the input type and if it's not empty.
(define (validate input)
  (displayln
    (string-append input
      (cond
        ( (not(string? input)) "  Not a String!" )
        ( (not(non-empty-string? (string-normalize-spaces input))) "  No Input" )
        ;;Apends the input with an EOL character `#\newline` and calls the first rule S.
        ( #t (ruleS (append (string-split (string-normalize-spaces input)) '(#\newline))) )
      )
    )
  )
)


;;Compares the input and the expected token (strings).
(define (matchToken input token)
   (cond
     ( (eq? (car input) token) #t )
     (#t #f)
   )
)


;;Validates a table/column name with the regular expression.
(define (validateName input)
  (cond
    ( (regexp-match #rx"^[_a-zA-Z][_a-zA-Z0-9]*$" (car input)) #t )
    ( (regexp-match #rx"^\".+\"$" (car input)) #t )
    ( (regexp-match #rx"^\\[.+\\]$" (car input)) #t )
    ( #t #f )
  )
)


;;Displays an error message.
(define (error message)
  message
  ;(begin
    ;(write message)
    ;#f
  ;)
)


;;Rule: S -> select A
(define (ruleS input)
  (cond
    ( (matchToken input "SELECT") (ruleA (cdr input)) ) ;;Expects the first token SELECT and calls the following rule.
    ( #t (error " SELECT Expected!") )
  )
)


;;Rule: A -> all B | distinct B | distinctrow B | B
;;These tokens are optional. This rule is skipped if no matching token is provided.
(define (ruleA input)
  (cond
    ( (matchToken input "ALL") (ruleB (cdr input)) )
    ( (matchToken input "DISTINCT") (ruleB (cdr input)) )
    ( (matchToken input "DISTINCTROW") (ruleB (cdr input)) )
    ( #t (ruleB input) )
  )
)


;;Rule: B -> * form E | C
(define (ruleB input)
  (cond
    ( (matchToken input "*") (cond ( (matchToken (cdr input) "FROM") (ruleE (cddr input)) ) ( #t (error " FROM Expected!") ) ) )
    ( #t (ruleC input) )
  )
)


;;Rule: C -> column D
;;Expects a column and validates its name.
(define (ruleC input)
  (cond
    ( (not (member (car input) tokens)) (cond ( (validateName input) (ruleD (cdr input)) ) ( #t (error " Invalid Column Name!") ) ) )
    ( #t (error " Column Reference Expected!") )
  )
)


;;Rule: D -> , C | from E
(define (ruleD input)
  (cond
    ( (matchToken input ",") (ruleC (cdr input)) )
    ( (matchToken input "FROM") (ruleE (cdr input)) )
    ( #t (error " FROM Expected!") )
  )
)


;;Rule: E -> table F
(define (ruleE input)
  (cond
    ( (not (member (car input) tokens))  (cond ( (validateName input)  (ruleF (cdr input)) ) ( #t (error " Invalid Table Name!")) ) )
    ( #t (error " Table Reference Expected!") )
  )
)


;;Rule: F -> ;ε
;;The final rule which expects the SQL query tereminator followed by a #\newline character.
(define (ruleF input)
  (cond
    ( (matchToken input ";") (cond ( (matchToken (cdr input) #\newline) " Valid Query" ) ( #t (error " EOF Expected!") ) ) )
    ( #t (error " Terminator Expected!") )
  )
)

;;╔══════════════════════╗
;;║ EXAMPLE CALLS/TESTS: ║
;;╚══════════════════════╝

;;Valid inputs:
(displayln "Valid inputs:")
(validate "SELECT * FROM table ;")
(validate "SELECT column FROM table ;")
(validate "SELECT col1 , col2 FROM table ;")
(validate "SELECT DISTINCT col1 , col2 FROM table ;")
(validate "SELECT [col1] , [col2] FROM \"table\" ;")

(displayln "")

;;Invalid inputs:
(displayln "Invalid inputs:")
(validate "SELEC * FROM table ;")
(validate "SELECT FROM table ;")
(validate "SELECT col1 , 2 FROM table ;")
(validate "SELECT * FOR table ;")
(validate "SELECT * FROM table")
(validate "SELECT * FROM table ; ;")
