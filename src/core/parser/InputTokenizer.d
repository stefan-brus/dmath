/**
 * This module takes a string of user input, and returns an array of tokens.
 * The tokens are returned in the order they were parsed, no syntax error checking is done here.
 *
 * Example usage:
 *
 * InputTokenizer tokenizer = new InputTokenizer;
 * Token[] tokens = tokenizer.parse(str);
 */

module src.core.parser.InputTokenizer;


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

    private char[] number_buf;


    /**
     * Buffer for the string token currently being parsed
     */

    private char[] str_buf;


    /**
     * Parses a string into an array of tokens
     *
     * Params:
     *      str = The string to parse
     *
     * Returns:
     *      The array of tokens found in the string
     */

    public Token[] parse ( char[] str )
    {
        Token[] tokens;

        foreach ( c; str )
        {
            if ( isNumeric([c]) || c == '.' )
            {
                this.number_buf ~= c;
            }
            else if ( isValidChar(c) )
            {
                this.str_buf ~= c;
            }
            else
            {
                Token token;

                if ( this.number_buf.length > 0 )
                {
                    tokens ~= this.addNumberToken;
                    this.number_buf.length = 0;
                }

                if ( this.str_buf.length > 0 )
                {
                    tokens ~= this.addStrToken;
                    this.str_buf.length = 0;
                }

                if ( isOperator([c]) )
                {
                    token = createOperator([c]);
                }

                tokens ~= token;
            }
        }

        if ( this.number_buf.length > 0 )
        {
            tokens ~= this.addNumberToken;
            this.number_buf.length = 0;
        }

        if ( this.str_buf.length > 0 )
        {
            tokens ~= this.addStrToken;
            this.str_buf.length = 0;
        }

        return tokens;
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
}