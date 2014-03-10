/**
 * Utility functions for operating on strings
 */

module src.core.util.String;

/**
 * Imports
 */

private import std.ascii;


/**
 * Checks if a given character is valid
 * NOTE: Currently follows the lexical rules of DMath for string tokens
 *
 * Params:
 *      c = The character to validate
 *
 * Returns:
 *      True if c is valid, false otherwise
 */

public bool isValidChar ( char c )
{
    return isAlpha(c) || c == '_';
}


/**
 * Checks if a given character is whitespace
 *
 * Params:
 *      c = The character to check
 *
 * Returns:
 *      True if c is whitespace, false otherwise
 */

public bool isWhitespace ( char c )
{
    if ( c == ' ' || c == '\n' || c == '\r' || c == '\t' )
    {
        return true;
    }
    else
    {
        return false;
    }
}


/**
 * Removes all whitespace characters from the given string
 *
 * Params:
 *      str = The string to remove whitespace from
 *
 * Returns:
 *      The string with whitespace removed
 */

public char[] removeWhitespace ( char[] str )
{
    char[] result;

    foreach ( c; str )
    {
        if ( !isWhitespace(c) )
        {
            result ~= c;
        }
    }

    return result;
}


/**
 * Unittests
 */

unittest
{
    /**
     * Error message
     */

    const err_msg = "String unittests failed";


    /**
     * isValidChar
     */

    assert(isValidChar('a'), err_msg);
    assert(isValidChar('Q'), err_msg);
    assert(isValidChar('_'), err_msg);
    assert(!isValidChar('2'), err_msg);
    assert(!isValidChar('+'), err_msg);


    /**
     * isWhitespace
     */

    assert(isWhitespace(' '), err_msg);
    assert(isWhitespace('\r'), err_msg);
    assert(isWhitespace('\n'), err_msg);
    assert(isWhitespace('\t'), err_msg);
    assert(!isWhitespace('a'), err_msg);
    assert(!isWhitespace('2'), err_msg);


    /**
     * removeWhitespace
     */

    assert(removeWhitespace(cast(char[])"") == "", err_msg);
    assert(removeWhitespace(cast(char[])"abc") == "abc", err_msg);
    assert(removeWhitespace(cast(char[])" he    \t\r\n ll   o ") == "hello", err_msg);
}