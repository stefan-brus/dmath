DMath
=====

Mathematical expression evaluator written in D.

Usage examples
=====

Evaluate a file containing DMath expressions:
```
dmath -f math.dmath
```

Command line interface example:
```
$ dmath
Welcome to DMath.
Enter expressions, or type 'quit' to quit.
> 1 + 2
3
> 9 * 3 ^ (4 - 2)
81
> var = 4 * 4
16
> func(x) = 2 * x + 3
0
> func(var)
35
```
