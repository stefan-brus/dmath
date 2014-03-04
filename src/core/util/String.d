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
    return isAlpha(c);
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
    assert(!isValidChar('2'), err_msg);
    assert(!isValidChar('+'), err_msg);
}