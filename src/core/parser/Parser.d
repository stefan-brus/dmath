/**
 * Builds an expression tree from an array of tokens using the Shunting-Yard algorithm:
 * http://en.wikipedia.org/wiki/Shunting-yard_algorithm
 *
 * Example usage:
 *
 * Parser parser = new Parser;
 * Exp exp = parser.parse(tokens); // tokens is an array of Token[] from InputTokenizer
 */

module src.core.parser.Parser;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.parser.Tokens;

private import src.core.util.container.Queue;

private import src.core.util.container.Stack;


/**
 * Parse exception class
 */

public class ParseException : Exception
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
 * Parser class
 */

public class Parser
{
    /**
     * Postfix expression queue
     */

    private Queue!Token post_queue;


    /**
     * Operator stack
     */

    private Stack!OpToken op_stack;


    /**
     * Expression stack
     */

    private Stack!Exp exp_stack;


    /**
     * Constructor
     */

    public this ( )
    {
        this.post_queue = new Queue!Token;
        this.op_stack = new Stack!OpToken;
        this.exp_stack = new Stack!Exp;
    }


    /**
     * Parse an array of tokens and generate an expression tree
     *
     * Params:
     *      tokens = The token array
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ParseException: If unknown or mismatched token is found
     */

    public Exp parse ( Token[] tokens )
    {
        Exp expression;

        this.post_queue.clear;
        this.op_stack.clear;
        this.exp_stack.clear;
        this.parseTokens(tokens);

        expression = this.buildExpression;

        return expression;
    }


    /**
     * Reset the state of the parser
     */

    public void reset ( )
    {
        this.post_queue.clear;
        this.op_stack.clear;
        this.exp_stack.clear;
    }


    /**
     * Parse tokens according to the Shunting-Yard algorithm
     * Unknown or mismatched tokens throw exceptions
     *
     * Params:
     *      tokens = The tokens to parse
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ParseException: If unknown or mismatched token is found
     */

    private Exp parseTokens ( Token[] tokens )
    {
        Exp result;

        foreach ( t; tokens )
        {
            if ( cast(NumToken)t )
            {
                this.post_queue.enqueue(cast(NumToken)t);
            }
            else if ( cast(OpToken)t )
            {
                auto op_tok = cast(OpToken)t;

                while ( this.op_stack.size > 0 )
                {
                    if ( ( op_tok.left_assoc && op_tok.precedence == this.op_stack.top.precedence ) ||
                         ( op_tok.precedence < this.op_stack.top.precedence ) )
                    {
                        this.queueOperator(this.op_stack.pop);
                    }
                    else
                    {
                        break;
                    }
                }

                this.op_stack.push(op_tok);
            }
            else
            {
                auto msg = "Unknown token: " ~ t.str;
                throw new ParseException(msg);
            }
        }

        while ( this.op_stack.size > 0 )
        {
            this.queueOperator(this.op_stack.pop);
        }

        return result;
    }


    /**
     * Checks the type of the operator and adds the appropriate token to the queue
     * Unknown tokens throw exceptions
     *
     * Params:
     *      token = The operator token
     *
     * Throws:
     *      ParseException: If unknown token is foun
     */

    private void queueOperator ( OpToken token )
    {
        if ( cast(PlusToken)token )
        {
            this.post_queue.enqueue(cast(PlusToken)token);
        }
        else if ( cast(MinusToken)token )
        {
            this.post_queue.enqueue(cast(MinusToken)token);
        }
        else if ( cast(MultiToken)token )
        {
            this.post_queue.enqueue(cast(MultiToken)token);
        }
        else if ( cast(DivToken)token )
        {
            this.post_queue.enqueue(cast(DivToken)token);
        }
        else if ( cast(ExpToken)token )
        {
            this.post_queue.enqueue(cast(ExpToken)token);
        }
        else
        {
            auto msg = "Unknown operator: " ~ token.str;
            throw new ParseException(msg);
        }
    }


    /**
     * Build an expression tree
     * Uses the tokens stored in reverse polish notation in the postfix queue
     * Unknown or mismatched tokens throw exceptions
     *
     * Returns:
     *      The generated expression
     *
     * Throws:
     *      ParseException: If mismatched or unknown token is found
     */

    private Exp buildExpression ( )
    {
        Exp result;

        while ( this.post_queue.size > 0 )
        {
            auto token = this.post_queue.dequeue;

            this.addExp(token);
        }

        if ( this.exp_stack.size == 1)
        {
            result = this.exp_stack.pop;
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
            throw new ParseException(msg);
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