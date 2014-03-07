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
     * Constructor
     */

    public this ( )
    {
        this.post_queue = new Queue!Token;
        this.op_stack = new Stack!OpToken;
    }


    /**
     * Parse an array of tokens and create a queue of tokens in postfix notation
     *
     * Params:
     *      tokens = The token array
     *
     * Returns:
     *      The postfix queue
     *
     * Throws:
     *      ParseException: If unknown or mismatched token is found
     */

    public Queue!Token parse ( Token[] tokens )
    {
        this.post_queue.clear;
        this.op_stack.clear;
        this.parseTokens(tokens);

        return this.post_queue;
    }


    /**
     * Reset the state of the parser
     */

    public void reset ( )
    {
        this.post_queue.clear;
        this.op_stack.clear;
    }


    /**
     * Parse tokens according to the Shunting-Yard algorithm
     * Unknown or mismatched tokens throw exceptions
     *
     * Params:
     *      tokens = The tokens to parse
     *
     * Throws:
     *      ParseException: If unknown or mismatched token is found
     */

    private void parseTokens ( Token[] tokens )
    {
        foreach ( t; tokens )
        {
            if ( cast(NumToken)t )
            {
                this.post_queue.enqueue(cast(NumToken)t);
            }
            else if ( cast(LParenToken)t )
            {
                this.op_stack.push(cast(LParenToken)t);
            }
            else if ( cast(RParenToken)t )
            {
                while ( this.op_stack.top && !cast(LParenToken)this.op_stack.top )
                {
                    this.queueOperator(this.op_stack.pop);
                }

                if ( cast(LParenToken)this.op_stack.top )
                {
                    this.op_stack.pop;
                }
                else
                {
                    char[] msg = cast(char[])"Mismatched parentheses";
                    throw new ParseException(msg);
                }
            }
            else if ( cast(OpToken)t )
            {
                auto op_tok = cast(OpToken)t;

                while ( this.op_stack.size > 0 && !cast(ParenToken)this.op_stack.top )
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
                char[] msg = "Unknown token: " ~ t.str;
                throw new ParseException(msg);
            }
        }

        while ( this.op_stack.size > 0 )
        {
            this.queueOperator(this.op_stack.pop);
        }
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
}