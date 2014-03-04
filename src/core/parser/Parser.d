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
            auto tok = this.post_queue.dequeue;

            if ( cast(NumToken)tok )
            {
                auto exp = new Num((cast(NumToken)tok).value);
                this.exp_stack.push(exp);
            }
            else if ( cast(PlusToken)tok )
            {
                auto exp = new Add;
                exp.right = this.exp_stack.pop;
                exp.left = this.exp_stack.pop;
                this.exp_stack.push(exp);
            }
            else if ( cast(MinusToken)tok )
            {
                auto exp = new Sub;
                exp.right = this.exp_stack.pop;
                exp.left = this.exp_stack.pop;
                this.exp_stack.push(exp);
            }
        }

        if ( this.exp_stack.size == 1)
        {
            result = this.exp_stack.pop;
        }

        return result;
    }
}