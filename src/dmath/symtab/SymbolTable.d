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

module dmath.symtab.SymbolTable;


/**
 * Imports
 */

private import dmath.absyn.Expression;

private import dmath.symtab.Symbols;

private import dmath.util.container.HashMap;

private import dmath.util.tmpl.Singleton;


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

    public this ( string msg )
    {
        super(msg);
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

    private HashMap!(string, Symbol) sym_map;


    /**
     * Put a constant into the symbol table
     *
     * Constants cannot be overwritten by the user
     *
     * Params:
     *      name = The name of the constant
     *      value = The value of the constant
     */

    public void putConstant ( string name, double value )
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

    public void putFunction ( string name, Exp exp, string[] args )
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

    public void opIndexAssign ( Exp exp, string var )
    {
        if ( var in this.sym_map && cast(Constant)this.sym_map[var] )
        {
            auto msg = "Cannot overwrite constant " ~ var;
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

    public Symbol opIndex ( string var )
    {
        if ( !(var in this.sym_map) )
        {
            auto msg = "Symbol " ~ var ~ " not defined";
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

    public bool opIn_r ( string var )
    {
        return var in this.sym_map;
    }


    /**
     * Foreach operator
     * Iterates over the internal hash map
     *
     * Params:
     *      dg = The opApply delegate
     *
     * Returns:
     *      Magic
     */

    public int opApply ( int delegate ( ref string key, ref Symbol val ) dg )
    {
        int result = 0;

        foreach ( name, sym; this.sym_map )
        {
            result = dg(name, sym);

            if ( result > 0 )
            {
                break;
            }
        }

        return result;
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
        this.sym_map = new HashMap!(string, Symbol);
    }
}