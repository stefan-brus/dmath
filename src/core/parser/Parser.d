/**
 * Builds a queue of tokens in reverse polish notation according to the following:
 * http://en.wikipedia.org/wiki/Shunting-yard_algorithm
 *
 * Example usage:
 *
 * Parser parser = new Parser;
 * auto postfix_queue = parser.parse(tokens); // tokens is an array of Token[] from InputTokenizer
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

    public this ( string msg )
    {
        super(msg);
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
     * Whether or not the currently parsed string is an assignment expression
     */

    private bool is_assignment;


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
     *      is_assignment = Whether or not this expression is an assignment
     *
     * Returns:
     *      The postfix queue
     *
     * Throws:
     *      ParseException: If unknown or mismatched token is found
     */

    public Queue!Token parse ( Token[] tokens, out bool is_assignment )
    {
        this.reset;
        this.parseTokens(tokens);

        is_assignment = this.is_assignment;

        return this.post_queue;
    }


    /**
     * Reset the state of the parser
     */

    public void reset ( )
    {
        this.post_queue.clear;
        this.op_stack.clear;
        this.is_assignment = false;
    }


    /**
     * Parse tokens according to the Shunting-Yard algorithm
     *
     * Counts the number of arguments to a function
     * Stores these in a stack in case of more function calls
     *
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
        auto arg_counts = new Stack!uint;

        this.is_assignment = false;

        foreach ( t; tokens )
        {
            if ( cast(NumToken)t )
            {
                this.post_queue.enqueue(cast(NumToken)t);
            }
            else if ( cast(StrToken)t )
            {
                this.post_queue.enqueue(cast(StrToken)t);
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

                    if ( cast(FnToken)this.op_stack.top )
                    {
                        (cast(FnToken)this.op_stack.top).args = arg_counts.top;
                        this.queueOperator(this.op_stack.pop);
                        arg_counts.pop;
                    }
                }
                else
                {
                    auto msg = "Mismatched parentheses";
                    throw new ParseException(msg);
                }
            }
            else if ( cast(FnToken)t )
            {
                this.op_stack.push(cast(FnToken)t);
                arg_counts.push(1);
            }
            else if ( cast(SepToken)t )
            {
                bool found_paren = cast(LParenToken)this.op_stack.top !is null;

                while ( !found_paren )
                {
                    this.queueOperator(this.op_stack.pop);

                    if ( cast(LParenToken)this.op_stack.top )
                    {
                        found_paren = true;
                    }
                }

                if ( !found_paren )
                {
                    auto msg = "Mismatched parentheses";
                    throw new ParseException(msg);
                }

                arg_counts.push(arg_counts.pop + 1);
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
                auto msg = "Unknown token: " ~ t.str;
                throw new ParseException(cast(string)msg);
            }
        }

        while ( this.op_stack.size > 0 )
        {
            this.queueOperator(this.op_stack.pop);
        }
    }


    /**
     * Checks the type of the token and adds the appropriate token to the queue
     *
     * Handles operator tokens and function tokens
     *
     * Unknown tokens throw exceptions
     *
     * Params:
     *      token = The token
     *
     * Throws:
     *      ParseException: If unknown token is foun
     */

    private void queueOperator ( OpToken token )
    {
        if ( cast(FnToken)token )
        {
            this.post_queue.enqueue(cast(FnToken)token);
        }
        else if ( cast(PlusToken)token )
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
        else if ( cast(AssignToken)token )
        {
            this.is_assignment = true;
            this.post_queue.enqueue(cast(AssignToken)token);
        }
        else
        {
            auto msg = "Unknown operator: " ~ token.str;
            throw new ParseException(msg);
        }
    }
}