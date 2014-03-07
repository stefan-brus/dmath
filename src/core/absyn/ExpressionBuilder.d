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

private import src.core.absyn.Expression;

private import src.core.parser.Tokens;

private import src.core.util.container.Queue;

private import src.core.util.container.Stack;


/**
 * Expression building exception class
 */

public class ExpException : Exception
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
 * Expression builder class
 */

public class ExpressionBuilder
{
    /**
     * Expression stack
     */

    private Stack!Exp exp_stack;


    /**
     * Constructor
     */

    public this ( )
    {
        this.exp_stack = new Stack!Exp;
    }


    /**
     * Build an expression tree
     * Uses the tokens stored in reverse polish notation in the given postfix queue
     * Unknown or mismatched tokens throw exceptions
     *
     * Params:
     *      post_queue = The postfix token queue
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ParseException: If mismatched or unknown token is found
     */

    public Exp buildExpression ( Queue!Token post_queue )
    {
        Exp result;

        while ( post_queue.size > 0 )
        {
            auto token = post_queue.dequeue;

            this.addExp(token);
        }

        if ( this.exp_stack.size == 1)
        {
            result = this.exp_stack.pop;
        }
        else
        {
            char[] msg = cast(char[])"Mismatched tokens in expression";
            throw new ExpException(msg);
        }

        return result;
    }


    /**
     * Adds an expression to the stack based on the given token
     *
     * Params:
     *      token = The token
     *
     * Throws:
     *      ParseException: If unknown token is given
     */

    private void addExp ( Token token )
    {
        if ( cast(NumToken)token )
        {
            this.addNum(cast(NumToken)token);
        }
        else if ( cast(PlusToken)token )
        {
            this.addBinOp!Add;
        }
        else if ( cast(MinusToken)token )
        {
            this.addBinOp!Sub;
        }
        else if ( cast(MultiToken)token )
        {
            this.addBinOp!Multi;
        }
        else if ( cast(DivToken)token )
        {
            this.addBinOp!Div;
        }
        else if ( cast(ExpToken)token )
        {
            this.addBinOp!Pow;
        }
        else
        {
            auto msg = "Unknown expression: " ~ token.str;
            throw new ExpException(msg);
        }
    }


    /**
     * Adds a number expression to the stack based on the given token
     *
     * Params:
     *      token = The token to get the value from
     */

    private void addNum ( NumToken token )
    {
        auto exp = new Num(token.value);
        this.exp_stack.push(exp);
    }


    /**
     * Adds a binary operation expression of the given type to the stack
     *
     * Template Params:
     *      T = The expression type to add to the stack
     */

    private void addBinOp ( T : BinOp ) ( )
    {
        auto exp = new T;
        exp.right = this.exp_stack.pop;
        exp.left = this.exp_stack.pop;
        this.exp_stack.push(exp);
    }
}