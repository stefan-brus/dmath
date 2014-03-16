/**
 * Utilities for manipulating expression trees
 */

module src.core.absyn.util.ExpTree;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.util.tmpl.Singleton;


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

        new_exp.left = new_left;
        new_exp.right = new_right;

        return new_exp;
    }
}