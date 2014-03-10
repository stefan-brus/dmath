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

private import src.core.util.container.HashMap;


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

public class SymbolTable
{
    /**
     * Singleton instance
     */

    private static SymbolTable _instance;


    /**
     * Internal variable name => expression map
     */

    private HashMap!(char[], Exp) var_map;


    /**
     * Constructor
     *
     * Private, use static instance() method to get instance
     */

    private this ( )
    {
        this.var_map = new HashMap!(char[], Exp);
    }


    /**
     * Singleton instance method
     *
     * Returns:
     *      The singleton instance
     */

    public static SymbolTable instance ( )
    {
        if ( _instance is null )
        {
            _instance = new SymbolTable;
        }

        return _instance;
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
        this.var_map[var] = exp;
    }


    /**
     * Index operator
     *
     * Params:
     *      var = The variable name string
     *
     * Returns:
     *      The value of the given variable
     *
     * Throws:
     *      SymtabException if the variable is not defined
     */

    public Exp opIndex ( char[] var )
    {
        if ( !(var in this.var_map) )
        {
            char[] msg = "Variable " ~ var ~ " not defined";
            throw new SymtabException(msg);
        }

        return this.var_map[var];
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
        return var in this.var_map;
    }


    /**
     * Reset the symbol table
     */

    public void reset ( )
    {
        this.var_map.clear;
    }
}