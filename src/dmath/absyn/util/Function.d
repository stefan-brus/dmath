/**
 * Utilities for function expressions
 */

module dmath.absyn.util.Function;


/**
 * Imports
 */

private import dmath.absyn.util.ExpTree;

private import dmath.absyn.util.Type;

private import dmath.absyn.Expression;

private import dmath.symtab.Symbols;

private import dmath.symtab.SymbolTable;

private import dmath.util.tmpl.Singleton;

private import dmath.util.Array;

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
     * Does type inference
     * Returns the expression with replaced arguments
     *
     * Params:
     *      name = The name of the function
     *      args = The argument list
     *
     * Returns:
     *      The function expression with replaced arguments
     */

    public Exp call ( string name, Exp[] args )
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

        if ( !cast(Function)SymbolTable()[name] )
        {
            auto msg = "Not a function: " ~ name;
            throw new ExpException(msg);
        }

        Function fn_sym = cast(Function) SymbolTable()[name];

        if ( fn_sym.args.length != args.length )
        {
            auto msg = format("Mismatched arguments to function %s: Expected %s, got %s", name, fn_sym.args.length, args.length);
            throw new ExpException(msg);
        }

        return TypeUtil().infer(ExpUtil().replace(fn_sym.exp.copy, &replace_dg));
    }


    /**
     * Put a function in the symbol table
     *
     * Params:
     *      name = The function name
     *      exp = The function expression
     *      args = The function arguments
     */

    public void putFunction ( string name, Exp exp, string[] args )
    {
        auto replaced_exp = this.replaceArgRefs(exp, args);

        SymbolTable().putFunction(name, replaced_exp, args);
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

    public Exp replaceArgRefs ( Exp exp, string[] args )
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

        return ExpUtil().replace(exp, &replace_dg);
    }
}