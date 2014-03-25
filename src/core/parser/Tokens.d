/**
 * Module containing parser token class hierarchy
 */

module src.core.parser.Tokens;


/**
 * Imports
 */

private import std.conv;

private import std.string;


/**
 * Base token class
 */

public class Token
{
    /**
     * The string representation of this token
     */
    protected string _str;


    /**
     * Constructor
     *
     * Params:
     *      str = The token string
     */

    public this ( string str )
    {
        this._str = str;
    }


    /**
     * Convert this token to a string
     *
     * Returns:
     *      The string representation of this token
     */

    public string str ( )
    {
        return this._str;
    }
}


/**
 * String token class
 */

public class StrToken : Token
{
    /**
     * Constructor
     *
     * Params:
     *      str = The string representation of this token
     */

    public this ( string str )
    {
        super(str);
    }
}


/**
 * Number token class
 * Stores the value internally as a double
 */

public class NumToken : Token
{

    /**
     * The value of this number
     */

    private double _value;


    /**
     * Constructor
     *
     * Params:
     *      str = The string representation of this token
     *      value = The value of this number
     */
    public this ( string str, double value )
    {
        super(str);
        this._value = value;
    }


    /**
     * Get the numeric value of this token
     */

    public double value ( )
    {
        return this._value;
    }
}


/**
 * Base operator token class
 */

public class OpToken : Token
{
    /**
     * The precedence of this operator
     */

    public const uint precedence;


    /**
     * Whether or not this operator is left associative
     */

    public const bool left_assoc;


    /**
     * Constructor
     *
     * Params:
     *      str = The token string
     *      precedence = This operator's precedence
     *      left_assoc = Whether or not this operator is left associative
     */

    public this ( string str, uint precedence, bool left_assoc )
    {
        super(str);
        this.precedence = precedence;
        this.left_assoc = left_assoc;
    }
}


/**
 * Function token class
 */

public class FnToken : OpToken
{
    /**
     * The number of arguments this function has
     */

    public size_t args;


    /**
     * Constructor
     *
     * Params:
     *      str = The token string
     */

    public this ( string str )
    {
        super(str, 10000, true);
    }
}


/**
 * List separator token class
 */

public class SepToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super(",", 10000, true);
    }
}


/**
 * Parenthesis token base class
 */

public class ParenToken : OpToken
{
    /**
     * Constructor
     *
     * Params:
     *      str = The token string
     */

    public this ( string str )
    {
        super(str, 0, true);
    }
}


/**
 * Left parenthesis token class
 */

public class LParenToken : ParenToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("(");
    }
}


/**
 * Right parenthesis token class
 */

public class RParenToken : ParenToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super(")");
    }
}


/**
 * Plus token class
 */

public class PlusToken : OpToken
{

    /**
     * Constructor
     */

    public this ( )
    {
        super("+", 10, true);
    }
}

/**
 * Minus token class
 */

public class MinusToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("-", 10, true);
    }
}


/**
 * Multiplication token class
 */

public class MultiToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("*", 20, true);
    }
}

/**
 * Division token class
 */

public class DivToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("/", 20, true);
    }
}


/**
 * Exponent token class
 */

public class ExpToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("^", 30, false);
    }
}


/**
 * Assignment token class
 */

public class AssignToken : OpToken
{
    /**
     * Constructor
     */

    public this ( )
    {
        super("=", 0, false);
    }
}


/**
 * Creates a number token from the given string
 *
 * Params:
 *      str = The number string
 *
 * Returns:
 *      A number token
 */

public NumToken createNumber ( string str )
in
{
    assert(isNumeric(str), "Invalid number string");
}
body
{
    NumToken result;

    double value = to!double(str);

    result = new NumToken(str, value);

    return result;
}


/**
 * Creates a string token from the given string
 *
 * Params:
 *      str = The string
 *
 * Returns:
 *      A string token
 */

public StrToken createString ( string str )
{
    return new StrToken(str);
}


/**
 * Creates a function token from the given string
 *
 * Params:
 *      str = The string
 *
 * Returns:
 *      A function token
 */

public FnToken createFunction ( string str )
{
    return new FnToken(str);
}


/**
 * Checks if a string is a list separator token
 *
 * Params:
 *      str = The string to check
 *
 * Returns:
 *      True if the string is a list separator
 */

public bool isSeparator ( string str )
{
    return str == ",";
}


/**
 * Creates a list separator token
 *
 * Returns:
 *      A separator token
 */

public SepToken createSeparator ( )
{
    return new SepToken;
}


/**
 * Checks if a given string is a parenthesis
 *
 * Template Params:
 *      T = The parenthesis token type
 *
 * Params:
 *      str = The string to check
 */

public bool isParenthesis ( T : ParenToken ) ( string str )
{
    static if ( is(T == LParenToken) )
    {
        return str == "(";
    }
    else if ( is(T == RParenToken) )
    {
        return str == ")";
    }
    else
    {
        return false;
    }
}


/**
 * Creates a parenthesis token from the givne string
 *
 * Template Params:
 *      T = The parenthesis token type
 */

public T createParenthesis ( T : ParenToken ) ( )
{
    return new T;
}


/**
 * Checks if a given string is an operator
 *
 * Params:
 *      str = The string to check
 *
 * Returns:
 *      True if str is an operator, false otherwise
 */

public bool isOperator ( string str )
{
    switch ( str )
    {
        case "+":
            return true;
        case "-":
            return true;
        case "*":
            return true;
        case "/":
            return true;
        case "^":
            return true;
        case "=":
            return true;
        default:
            return false;
    }
}


/**
 * Creates an operator token from the given string
 *
 * Params:
 *      str = The operator string
 *
 * Returns:
 *      An operator token
 */

public OpToken createOperator ( string str )
in
{
    assert(isOperator(str), "Invalid operator string");
}
body
{
    OpToken result;

    switch ( str )
    {
        case "+":
            result = new PlusToken;
            break;
        case "-":
            result = new MinusToken;
            break;
        case "*":
            result = new MultiToken;
            break;
        case "/":
            result = new DivToken;
            break;
        case "^":
            result = new ExpToken;
            break;
        case "=":
            result = new AssignToken;
            break;
        default:
            assert(false, "Unknown operator");
    }

    return result;
}