/**
 * Symbol table module
 *
 * Stores variables in a hash table of string to expression entries
 *
 * Usage example:
 * auto symtab = SymbolTable.instance;
 * Exp exp = ... // pretend that exp represents 7 * 3
 * symtab["x"] = exp;
 * "x" in symtab; // true
 * symtab["x"].eval: // 21
 */

module src.core.symtab.SymbolTable;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.symtab.Symbols;

private import src.core.util.container.HashMap;

private import src.core.util.tmpl.Singleton;


/**
 * Symbol table exception class
 */

public class SymtabException : Exception
{
    /**
     * Constructor
     *
     * Params:
     *      msg = The error message
     */

    public this ( char[] msg )
    {
        super(cast(string)msg);
    }
}


/**
 * Symbol table class
 *
 * Implemented as a singleton
 */

public class SymbolTable : Singleton!(SymbolTable)
{
    /**
     * Internal variable name => symbol map
     */

    private HashMap!(char[], Symbol) sym_map;


    /**
     * Put a constant into the symbol table
     *
     * Constants cannot be overwritten by the user
     *
     * Params:
     *      name = The name of the constant
     *      value = The value of the constant
     */

    public void putConstant ( char[] name, double value )
    {
        this.sym_map[name] = new Constant(new Num(value));
    }


    /**
     * Puts a function into the symbol table
     *
     * Params:
     *      name = The name of the function
     *      exp = The function expression
     *      args = The argument list
     */

    public void putFunction ( char[] name, Exp exp, char[][] args )
    {
        if ( name in this.sym_map && cast(Function)this.sym_map[name] )
        {
            this.sym_map[name].exp = exp;
            (cast(Function)this.sym_map[name]).args = args;
        }
        else
        {
            this.sym_map[name] = new Function(exp, args);
        }
    }


    /**
     * Index assignment operator
     *
     * Params:
     *      exp = The expression
     *      var = The variable name string
     */

    public void opIndexAssign ( Exp exp, char[] var )
    {
        if ( var in this.sym_map && cast(Constant)this.sym_map[var] )
        {
            char[] msg = "Cannot overwrite constant " ~ var;
            throw new SymtabException(msg);
        }

        if ( var in this.sym_map )
        {
            this.sym_map[var].exp = exp;
        }
        else
        {
            this.sym_map[var] = new Variable(exp);
        }
    }


    /**
     * Index operator
     *
     * Params:
     *      var = The variable name string
     *
     * Returns:
     *      The symbol for the given variable
     *
     * Throws:
     *      SymtabException if the variable is not defined
     */

    public Symbol opIndex ( char[] var )
    {
        if ( !(var in this.sym_map) )
        {
            char[] msg = "Symbol " ~ var ~ " not defined";
            throw new SymtabException(msg);
        }

        return this.sym_map[var];
    }


    /**
     * In operator
     *
     * Params:
     *      var = The variable name string
     *
     * Returns:
     *      True if the variable exists, false otherwise
     */

    public bool opIn_r ( char[] var )
    {
        return var in this.sym_map;
    }


    /**
     * Reset the symbol table
     */

    public void reset ( )
    {
        this.sym_map.clear;
    }


    /**
     * Initialize the symbol table
     */

    protected override void init ( )
    {
        this.sym_map = new HashMap!(char[], Symbol);
    }
}