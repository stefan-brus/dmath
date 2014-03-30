/**
 * Utility functions for operating on strings
 */

module dmath.util.String;

/**
 * Imports
 */

private import std.ascii;

private import std.string;


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

public string removeWhitespace ( string str )
{
    string result;

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
 * Checks if a given character is a comment, '#'
 *
 * Params:
 *      c = The character to check
 *
 * Returns:
 *      True if the character is a comment, false otherwise
 */

public bool isComment ( char c )
{
    return c == '#';
}


/**
 * Checks if a given string is a comment, I.E starts with '#'
 *
 * Params:
 *      str = The string to check
 *
 * Returns:
 *      True if the string is a comment, false otherwise
 */

public bool isComment ( string str )
{
    return str.length > 0 && isComment(strip(str)[0]);
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

    assert(removeWhitespace("") == "", err_msg);
    assert(removeWhitespace("abc") == "abc", err_msg);
    assert(removeWhitespace(" he    \t\r\n ll   o ") == "hello", err_msg);


    /**
     * isComment
     */

    assert(isComment('#'), err_msg);
    assert(!isComment('a'), err_msg);
}