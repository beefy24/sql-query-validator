## Description
The `sql-validator.rkt` is a string validator for very basic SQL SELECT queries, written in Racket language (LISP) as a learning exrecise. It is not a true input scanner or a recursive descent parser, but rather a trivial regular validator. This is a personal learning exercise with notes, and there may be mistakes.

## Notes for writing LL grammar rules
- The example below demonstrates how to convert a regular grammar, like the one shown in `sql-validator.rkt`, into a corresponding (context-free) LL1 grammar.
- An LL grammar can be implemented with an LL push-down automaton, while a regular grammar can be implemented with a simple finite state machine.

**The meaning of LL1:**
- L\_\_ &nbsp; &nbsp; The input is being scanned from left to right.  
- \_L\_ &nbsp; &nbsp; The leftmost variable is being expanded in each step.  
- \_\_1 &nbsp; &nbsp; The next rule is determined by looking one symbol ahead (to the right).  

### Example:
```
The original regular grammar rules:
S -> select A
A -> all B | distinct B | distinctrow B | B
B -> * form E | C
C -> column D
D -> , C | from E
E -> table F
F -> ;ε

The corresponding LL1 grammar rules:
S -> sAft;
A -> * | aB | cC
B -> * | cC
C -> ,cC | ε

Both grammars start at the variable S, and end after successfuly reading the terminal symbol ";".

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

Copyright (c) 2024 [beefy24](https://github.com/beefy24).