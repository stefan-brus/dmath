/**
 * Expression builder module
 *
 * Takes a queue of tokens that form a mathematical expression.
 * The tokens must be written in the order of reverse polish notation.
 * Returns the constructed expression tree.
 */

module src.core.absyn.ExpressionBuilder;


/**
 * Imports
 */

private import src.core.absyn.util.ExpTree;

private import src.core.absyn.Expression;

private import src.core.parser.Grammar;

private import src.core.util.Array;

private import pegged.peg;

private import std.conv;


/**
 * Expression builder class
 */

public class ExpressionBuilder
{
    /**
     * State to keep track of assignment lvalues
     */

    private bool assign;


    /**
     * Build an expression tree from the given parse tree
     *
     * Unknown or mismatched tokens throw exceptions
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ExpException: If mismatched or unknown parse token is found
     */

    public Exp build ( ParseTree p )
    {
        switch ( p.name )
        {
            case "DMath":
                return this.build(p.children[0]);

            case "DMath.Expr":
                return this.createExp(p);

            case "DMath.Assign":
                return this.createBinOp!Assign(p);

            case "DMath.Term":
                return this.createExp(p);

            case "DMath.Add":
                return this.createBinOp!Add(p);

            case "DMath.Sub":
                return this.createBinOp!Sub(p);

            case "DMath.Factor":
                return this.createExp(p);

            case "DMath.Mul":
                return this.createBinOp!Multi(p);

            case "DMath.Div":
                return this.createBinOp!Div(p);

            case "DMath.Comp":
                return this.createExp(p);

            case "DMath.Pow":
                return this.createBinOp!Pow(p);

            case "DMath.Primary":
                return this.build(p.children[0]);

            case "DMath.Parens":
                return this.build(p.children[0]);

            case "DMath.Neg":
                return this.createNum(p);

            case "DMath.Number":
                return this.createNum(p);

            case "DMath.Function":
                return this.createFn(p);

            case "DMath.Variable":
                return this.createVar(p);

            default:
                throw new ExpException("Unkown parse token");
        }
    }


    /**
     * Builds a list of expressions from the given parse tree
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The array of built expressions
     */

    private Exp[] buildList ( ParseTree p )
    in
    {
        assert(p.name == "DMath.TermList", "Not an expression list");
    }
    body
    {
        Exp[] result;

        foreach ( child; p.children )
        {
            if ( child.name == "DMath.Term" )
            {
                result ~= this.build(child);
            }
        }

        return result;
    }


    /**
     * Create an arbitrary expression from a given recursive parse token
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The created expression
     */

    private Exp createExp ( ParseTree p )
    in
    {
        assert(p.name == "DMath.Expr" || p.name == "DMath.Term" || p.name == "DMath.Factor" || p.name == "DMath.Comp", "Not a valid expression token");
    }
    body
    {
        Exp result;

        if ( p.name == "DMath.Expr" && p.children.length > 1 )
        {
            this.assign = true;
        }

        Exp left = this.build(p.children[0]);

        if ( p.name == "DMath.Expr" && p.children.length > 1 )
        {
            this.assign = false;
        }

        if ( p.children.length > 1 )
        {
            Exp prev = left;

            foreach ( child; p.children[1 .. $] )
            {
                result = build(child);
                result.left = prev;
                prev = result.copy;
            }
        }
        else
        {
            result = left;
        }

        return result;
    }


    /**
     * Create a binary operator expression, if the parse tree contains an operator
     *
     * Template Params:
     *      T = The type of operator expression to create
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The created expression
     */

    private Exp createBinOp ( T : BinOp ) ( ParseTree p )
    {
        Exp result = new T;
        result.right = this.build(p.children[0]);
        return result;
    }


    /**
     * Creates a number expression from the given parse tree
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The created number expression
     */

    private Exp createNum ( ParseTree p )
    in
    {
        assert(p.name == "DMath.Number" || p.name == "DMath.Neg", "Not a number token");
    }
    body
    {
        return new Num(to!double(flatten(p.matches)));
    }


    /**
     * Creates a variable expression from the given parse tree
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The created variable expression
     */

    private Exp createVar ( ParseTree p )
    in
    {
        assert(p.name == "DMath.Variable", "Not a variable token");
    }
    body
    {
        return new Var(p.matches[0]);
    }


    /**
     * Creates a function expression from the given parse tree
     *
     * Params:
     *      p = The parse tree
     *
     * Returns:
     *      The created function expression
     */
    private import std.stdio;
    private Exp createFn ( ParseTree p )
    in
    {
        assert(p.name == "DMath.Function", "Not a function token");
    }
    body
    {
        Exp result;

        auto args = this.buildList(p.children[1]);

        auto name = p.matches[0];

        if ( this.assign )
        {
            result = new FnDef(name, ExpUtil.instance.toStrList(args));
        }
        else
        {
            result = new FnCall(name, args);
        }

        return result;
    }
}