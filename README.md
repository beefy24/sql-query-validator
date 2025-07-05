## sql-query-validator
This is a simple string validator for SQL SELECT statements. It is written in Racket (a LISP dialect), and it is not a full input scanner or a recursive descent parser. It was created as part of a learning exercise and may contain mistakes.

## Notes
- The example below demonstrates the conversion of a regular grammar, the one implemented in `sql-validator.rkt`, into a corresponding (context-free) LL1 grammar.
- An LL grammar can be implemented with an LL push-down automaton, while a regular grammar can be implemented with a simple finite state machine.

The meaning of LL1:
- L\_\_ &nbsp; &nbsp; The input is being scanned from left to right.  
- \_L\_ &nbsp; &nbsp; The leftmost variable is being expanded in each step.  
- \_\_1 &nbsp; &nbsp; The next rule is determined by looking one symbol ahead (to the right).  

**Grammar rules:**  
```
Both grammars start at the variable S and end after successfully reading
the terminal symbol ";".  Uppercase letters represent variables, lowercase
letters/words represent SQL symbols.

The original regular grammar rules:
S -> select A
A -> all B | distinct B | distinctrow B | B
B -> * form E | C
C -> column D
D -> , C | from E
E -> table F
F -> ;ε

The equivalent LL1 grammar rules:
S -> sAft;
A -> * | aB | cC
B -> * | cC
C -> ,cC | ε

Parse table:
+----------+---+-----+---+--------------+--------+------+--------+-------+---+
| VARIABLE | * |  ,  | ; | ALL|DISTINCT | column | FROM | SELECT | table | ε |
+----------+---+-----+---+--------------+--------+------+--------+-------+---+
| A        | * |     |   | aB           | cC     |      |        |       |   |
| B        | * |     |   |              | cC     |      |        |       |   |
| C        |   | ,cC |   |              |        | ε    |        |       |   |
| S        |   |     |   |              |        |      | sAft;  |       |   |
+----------+---+-----+---+--------------+--------+------+--------+-------+---+

Used SQL symbols/KEYWORDS:
s - SELECT
a - ALL|DISTINCT|DISTINCTROW
* - symbol for all columns
c - column name
, - column separator
f - FROM
t - table name
; - query terminator
ε - empty expansion in the LL1 grammar / end of input in the regular grammar
```
