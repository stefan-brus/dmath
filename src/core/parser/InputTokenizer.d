/**
 * This module takes a string of user input, and returns an array of tokens.
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

private import std.string;


/**
 * Input tokenizer class
 */

public class InputTokenizer
{

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
            auto token = new Token([c]);
            tokens ~= token;
        }

        return tokens;
    }
}