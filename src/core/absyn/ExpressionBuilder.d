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
 * Expression builder class
 */

public class ExpressionBuilder
{
    /**
     * Expression stack
     */

    private Stack!Exp exp_stack;


    /**
     * Whether or not this expression is an assignment
     */

    private bool is_assignment;


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
     *      is_assignment = Whether or not this expression is an assignment
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ParseException: If mismatched or unknown token is found
     */

    public Exp buildExpression ( Queue!Token post_queue, bool is_assignment )
    {
        this.is_assignment = is_assignment;

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
            auto msg = "Mismatched tokens in expression";
            throw new ExpException(msg);
        }

        return result;
    }


    /**
     * Reset the expression builder
     */

    public void reset ( )
    {
        this.exp_stack.clear;
        this.is_assignment = false;
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
        else if ( cast(StrToken)token )
        {
            this.addVar(cast(StrToken)token);
        }
        else if ( cast(FnToken)token )
        {
            this.addFn(cast(FnToken)token);
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
        else if ( cast(AssignToken)token )
        {
            this.addBinOp!Assign;
        }
        else
        {
            auto msg = "Unknown expression: " ~ token.str;
            throw new ExpException(cast(string)msg);
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
     * Adds a variable expression to the stack based on the given token
     *
     * Params:
     *      token = The token to get the variable name from
     */

    private void addVar ( StrToken token )
    {
        auto exp = new Var(token.str);
        this.exp_stack.push(exp);
    }


    /**
     * Adds a function expression to the stack based on the given token
     * If is_assignment is true, adds an FnDef, otherwise an FnCall
     *
     * Params:
     *      token = The token to get function data from
     */

    private void addFn ( FnToken token )
    {
        Exp[] args;

        for ( uint i = 0; i < token.args; i++ )
        {
            args ~= this.exp_stack.pop;
        }

        if ( this.is_assignment )
        {
            string[] str_args;

            foreach ( arg; args )
            {
                str_args ~= arg.str;
            }

            auto exp = new FnDef(token.str, str_args);
            this.exp_stack.push(exp);
        }
        else
        {
            auto exp = new FnCall(token.str, args);
            this.exp_stack.push(exp);
        }
    }


    /**
     * Adds a binary operation expression of the given type to the stack
     *
     * Template Params:
     *      T = The expression type to add to the stack
     *
     * Throws:
     *      ExpException if trying to add an assignment to a non-variable expression
     */

    private void addBinOp ( T : BinOp ) ( )
    {
        auto exp = new T;
        exp.right = this.exp_stack.pop;
        static if ( is(T == Assign) )
        {
            if ( !cast(Var)this.exp_stack.top && !cast(FnDef)this.exp_stack.top )
            {
                throw new ExpException("Assignment must be to variable or function definition");
            }
        }
        exp.left = this.exp_stack.pop;
        this.exp_stack.push(exp);
    }
}