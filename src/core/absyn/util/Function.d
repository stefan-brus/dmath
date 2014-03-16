/**
 * Utilities for function expressions
 */

module src.core.absyn.util.Function;


/**
 * Imports
 */

private import src.core.absyn.util.ExpTree;

private import src.core.absyn.Expression;

private import src.core.symtab.Symbols;

private import src.core.symtab.SymbolTable;

private import src.core.util.tmpl.Singleton;

private import src.core.util.Array;

private import std.string;


/**
 * Function utility class
 *
 * Implemented as a singleton
 */

public class FnUtil : Singleton!(FnUtil)
{
    /**
     * Call a function
     *
     * Fetches the function from the symbol table
     * Replaces the FnArg expressions in the function expression with the actual arguments
     * Returns the expression with replaced arguments
     *
     * Params:
     *      name = The name of the function
     *      args = The argument list
     *
     * Returns:
     *      The function expression with replaced arguments
     */

    public Exp call ( char[] name, Exp[] args )
    {
        /**
         * Replace delegate
         */

        Exp replace_dg ( Exp exp )
        {
            if ( cast(FnArg)exp )
            {
                return args[(cast(FnArg)exp).idx];
            }
            else
            {
                return exp;
            }
        }

        if ( !cast(Function)SymbolTable.instance[name] )
        {
            char[] msg = "Not a function: " ~ name;
            throw new ExpException(msg);
        }

        Function fn_sym = cast(Function) SymbolTable.instance[name];

        if ( fn_sym.args.length != args.length )
        {
            char[] msg = format("Mismatched arguments to function %s: Expected %s, got %s", name, fn_sym.args.length, args.length);
            throw new ExpException(msg);
        }

        return ExpUtil.instance.replace(fn_sym.exp.copy, &replace_dg);
    }


    /**
     * Put a function in the symbol table
     *
     * Params:
     *      name = The function name
     *      exp = The function expression
     *      args = The function arguments
     */

    public void putFunction ( char[] name, Exp exp, char[][] args )
    {
        auto replaced_exp = this.replaceArgRefs(exp, args);

        SymbolTable.instance.putFunction(name, replaced_exp, args);
    }


    /**
     * Replace references to function arguments with argument expressions
     *
     * Params:
     *      exp = The function expression
     *      args = The function arguments
     *
     * Returns:
     *      The expression with replaced argument references
     */

    public Exp replaceArgRefs ( Exp exp, char[][] args )
    {
        /**
         * Replace delegate
         */

        Exp replace_dg ( Exp exp )
        {
            if ( cast(Var)exp && contains(args, exp.str) )
            {
                return new FnArg(exp.str, indexOf(args, exp.str));
            }
            else
            {
                return exp;
            }
        }

        return ExpUtil.instance.replace(exp, &replace_dg);
    }
}