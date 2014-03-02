/**
 * Module containing parser token class hierarchy
 */

module src.core.parser.Tokens;


/**
 * Base token class
 */

public class Token
{
    /**
     * The string representation of this token
     */
    protected char[] _str;


    /**
     * Constructor
     *
     * Params:
     *      str = The token string
     */

    public this ( char[] str )
    {
        this._str = str;
    }

    /**
     * Convert this token to a string
     *
     * Returns:
     *      The string representation of this token
     */

    public char[] str ( )
    {
        return this._str;
    }
}