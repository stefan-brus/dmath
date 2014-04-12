/**
 * Utilities for manipulating expression trees
 */

module dmath.absyn.util.ExpTree;


/**
 * Imports
 */

private import dmath.absyn.Expression;

private import dmath.util.tmpl.Singleton;


/**
 * Expression tree utility class
 *
 * Implemented as a singleton
 */

public class ExpUtil : Singleton!(ExpUtil)
{
    /**
     * Replace function delegate type
     *
     * Params:
     *      Exp = The expression to replace
     *
     * Returns:
     *      The replacement expression
     */

    private alias Exp delegate(Exp) ReplaceDg;


    /**
     * Search function delegate type
     *
     * Params:
     *      Exp = The current expression
     *
     * Returns:
     *      True or false
     */

    private alias bool delegate(Exp) SearchDg;


    /**
     * Replace expressions in the given tree using the given delegate
     *
     * Performs recursive depth-first tree traversal
     *
     * Params:
     *      exp = The expression tree
     *      dg = The replacer delegate
     *
     * Returns:
     *      The expression tree with replaced expressions
     */

    public Exp replace ( Exp exp, ReplaceDg dg )
    {
        if ( exp is null )
        {
            return exp;
        }

        Exp new_left = this.replace(exp.left, dg);
        Exp new_right = this.replace(exp.right, dg);
        Exp new_exp = dg(exp);

        if ( new_left )
        {
            new_exp.left = new_left;
        }

        if ( new_right )
        {
            new_exp.right = new_right;
        }

        return new_exp;
    }


    /**
     * Replace expressions in the given tree using the given replacer delegate,
     * if the given search delegate returns true
     *
     * If the serach delegate returns false, the sub expressions are not traversed
     *
     * Performs recursive depth-first tree traversal
     *
     * Params:
     *      exp = The expression tree
     *      search_dg = The search delegate
     *      replace_dg = The replacer delegate
     *
     * Returns:
     *      The expression tree with replaced expressions
     */

    public Exp replaceIf ( Exp exp, SearchDg search_dg, ReplaceDg replace_dg )
    {
        if ( exp is null || !search_dg(exp) )
        {
            return exp;
        }

        Exp new_left = this.replaceIf(exp.left, search_dg, replace_dg);
        Exp new_right = this.replaceIf(exp.right, search_dg, replace_dg);
        Exp new_exp = replace_dg(exp);

        if ( new_left )
        {
            new_exp.left = new_left;
        }

        if ( new_right )
        {
            new_exp.right = new_right;
        }

        return new_exp;
    }


    /**
     * Searches for an expression in the given expression tree
     *
     * Performs recursive depth-first tree traversal
     *
     * Params:
     *      exp = The expression tree
     *      dg = The search delegate
     *
     * Returns:
     *      True if the expression was found, false otherwise
     */

    public bool exists ( Exp exp, SearchDg dg )
    {
        if ( exp is null )
        {
            return false;
        }
        else if ( exists(exp.left, dg) )
        {
            return true;
        }
        else if ( exists(exp.right, dg) )
        {
            return true;
        }
        else
        {
            return dg(exp);
        }
    }


    /**
     * Transforms an expression list into a string list
     *
     * Params:
     *      exps = The expressions
     *
     * Returns:
     *      The generated string list
     */

    public string[] toStrList ( Exp[] exps )
    {
        string[] result;

        foreach ( exp; exps )
        {
            result ~= exp.str;
        }

        return result;
    }
}