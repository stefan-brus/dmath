/**
 * Module for the different types that can be stored in the symbol table
 */

module dmath.symtab.Symbols;


/**
 * Imports
 */

private import dmath.absyn.Expression;


/**
 * Base symbol class
 *
 * Contains an expression representing the value of the symbol
 */

 public abstract class Symbol
 {
    /**
     * The expression this symbol represents
     */

    public Exp exp;


    /**
     * Constructor
     *
     * Params:
     *      exp = The expression of this symbol
     */

    public this ( Exp exp )
    {
        this.exp = exp;
    }
 }


/**
 * Variable symbol
 */

public class Variable : Symbol
{
    /**
     * Constructor
     *
     * Params:
     *      exp = The expression of this symbol
     */

    public this ( Exp exp )
    {
        super(exp);
    }
}


/**
 * Constant symbol
 */

public class Constant : Symbol
{
    /**
     * Constructor
     *
     * Params:
     *      exp = The expression of this symbol
     */

    public this ( Exp exp )
    {
        super(exp);
    }
}


/**
 * Function symbol
 */

public class Function : Symbol
{
    /**
     * The list of arguments
     */

    public string[] args;


    /**
     * Constructor
     *
     * Params:
     *      exp = The expression of the function
     *      args = The argument list
     */

    public this ( Exp exp, string[] args )
    {
        super(exp);
        this.args = args;
    }
}