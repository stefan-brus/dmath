/**
 * This module takes a string of user input, and returns an array of parser tokens.
 * The tokens are returned in the order they were parsed, no syntax error checking is done here.
 *
 * Example usage:
 *
 * InputTokenizer tokenizer = new InputTokenizer;
 * Token[] tokens = tokenizer.parse(str);
 */

module src.core.lexer.InputTokenizer;


/**
 * Imports
 */

private import src.core.parser.Tokens;

private import src.core.util.String;

private import std.ascii;

private import std.string;


/**
 * Input tokenizer class
 */

public class InputTokenizer
{

    /**
     * Buffer for the number currently being parsed
     */

    private string number_buf;


    /**
     * Buffer for the string token currently being parsed
     */

    private string str_buf;


    /**
     * Buffer for the whitespace-stripped input string
     */

    private string stripped_str;


    /**
     * Buffer for parsed tokens
     */

    private Token[] token_buf;


    /**
     * Parses a string into an array of tokens
     *
     * Strips whitespace from the given string
     *
     * If a comment ('#') is encountered, the rest of the string is skipped
     *
     * Params:
     *      str = The string to parse
     *
     * Returns:
     *      The array of tokens found in the string
     */

    public Token[] parse ( string str )
    {
        this.token_buf.length = 0;

        this.stripped_str = removeWhitespace(str);

        foreach ( i, c; this.stripped_str )
        {
            if ( isComment(c) )
            {
                break;
            }
            else if ( this.isNegativeNum(i, c) )
            {
                this.number_buf ~= c;
            }
            else if ( isNumeric([c]) || c == '.' )
            {
                this.number_buf ~= c;
            }
            else if ( isValidChar(c) )
            {
                this.str_buf ~= c;
            }
            else if ( isParenthesis!LParenToken([c]) )
            {
                this.addBufferedTokens(true);
                this.token_buf ~= createParenthesis!LParenToken;
            }
            else if ( isParenthesis!RParenToken([c]) )
            {
                this.addBufferedTokens;
                this.token_buf ~= createParenthesis!RParenToken;
            }
            else if ( isSeparator([c]) )
            {
                this.addBufferedTokens;
                this.token_buf ~= createSeparator;
            }
            else
            {
                Token token;

                this.addBufferedTokens;

                if ( isOperator([c]) )
                {
                    token = createOperator([c]);
                }

                this.token_buf ~= token;
            }
        }

        this.addBufferedTokens;

        return this.token_buf;
    }


    /**
     * Reset the state of the tokenizer
     */

    public void reset ( )
    {
        this.number_buf.length = 0;
        this.str_buf.length = 0;
        this.stripped_str.length = 0;
        this.token_buf.length = 0;
    }


    /**
     * Adds tokens from the number and string buffers
     *
     * If lparen is true, contents of the string buffer will be added as a function token
     *
     * Params:
     *      lparen = Whether or not a left parenthesis has been found
     */

    private void addBufferedTokens ( bool lparen = false )
    {
        if ( this.number_buf.length > 0 )
        {
            this.token_buf ~= this.addNumberToken;
            this.number_buf.length = 0;
        }

        if ( this.str_buf.length > 0 )
        {
            if ( lparen )
            {
                this.token_buf ~= this.addFnToken;
            }
            else
            {
                this.token_buf ~= this.addStrToken;
            }

            this.str_buf.length = 0;
        }
    }


    /**
     * Checks if a given index and character from the stripped string
     * is the beginning of a negative number
     *
     * Peeks at the next and previous tokens to determine if a dash is
     * the start of a negative number or not.
     *
     * Params:
     *      i = The index
     *      c = The character
     *
     * Returns:
     *      True if it is at the start of a negative number, false otherwise
     */

    private bool isNegativeNum ( uint i, char c )
    {
        if ( (c == '-' && i < this.stripped_str.length - 1 && isNumeric([ this.stripped_str[i + 1] ])) &&
             (i == 0 || isOperator([ this.stripped_str[i - 1] ]) || isParenthesis!LParenToken([ this.stripped_str[i - 1] ])) )
        {
            return true;
        }
        else
        {
            return false;
        }
    }


    /**
     * Checks if a valid number string is present in the number buffer
     * If so, creates a number token and adds it to the given token array
     *
     * Returns:
     *      The created number token
     */

    private NumToken addNumberToken ( )
    {
        return createNumber(this.number_buf);
    }


    /**
     * Creates a new string token from the string buffer
     *
     * Returns:
     *      the created string token
     */

    private StrToken addStrToken ( )
    {
        return createString(this.str_buf);
    }


    /**
     * Creates a new function token from the string buffer
     *
     * Returns:
     *      The created function token
     */

    private FnToken addFnToken ( )
    {
        return createFunction(this.str_buf);
    }
}