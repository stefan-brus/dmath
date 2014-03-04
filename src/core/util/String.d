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
 * NOTE: Currently follows the lexical rules of DMath
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