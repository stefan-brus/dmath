/**
 * Contains the expression tree types
 */

module src.core.absyn.Expression;


/**
 * Imports
 */

private import src.core.symtab.SymbolTable;

private import std.conv;

private import std.string;


/**
 * Base expression class
 */

public abstract class Exp
{
    /**
     * Child expressions
     */

    public Exp left;

    public Exp right;


    /**
     * Abstract function to evaluate this expression
     */

    public abstract double eval ( );


    /**
     * Abstract function to get the string of this expression
     *
     * Returns:
     *      The string of this expression's value, and its children's string representations
     */

    public abstract char[] str ( );
}

/**
 * Number expression class
 */

public class Num : Exp
{
    /**
     * The value of this number expression
     */

    private double val;


    /**
     * Constructor
     *
     * Params:
     *      val = The numeric value
     */

    public this ( double val )
    {
       this.val = val;
    }


    /**
     * Evaluate this expression
     * Returns the numeric value
     */

    public override double eval ( )
    {
        return this.val;
    }


    /**
     * Get the string representation of this expression
     */

    public override char[] str ( )
    {
        return cast(char[])format("%s", this.eval);
    }
}


/**
 * Variable expression class
 */

public class Var : Exp
{
    /**
     * The variable name
     */

    private char[] name;


    /**
     * Symbol table reference
     */

    private SymbolTable symtab;


    /**
     * Constructor
     *
     * Params:
     *      name = The variable name
     *      symtab = The symbol table reference
     */

    public this ( char[] name )
    {
        this.name = name;
        this.symtab = SymbolTable.instance;
    }


    /**
     * Evaluate this expression
     *
     * Returns the value of the expression in the symbol table for this variable
     *
     * Returns:
     *      The value of the variable
     */

    public override double eval ( )
    {
        return this.symtab[name].eval;
    }


    /**
     * Get the string representation of this expression
     */

    public override char[] str ( )
    {
        return this.name;
    }
}


/**
 * Base binary operator class
 */

public abstract class BinOp : Exp
{
    /**
     * Binary operator evaluation delegate
     * Call a function on both child expressions
     */

    private alias double delegate(Exp, Exp) BinOpDg;


    /**
     * Child expression evaluator
     */

    private BinOpDg eval_dg;


    /**
     * The string representation of this operator
     */

    private char[] op_str;


    /**
     * Constructor
     *
     * Params:
     *      eval_dg = Child expression evaluator delegate
     *      op_str = The string representation of this operator
     */

    public this ( BinOpDg eval_dg, char[] op_str )
    {
        this.eval_dg = eval_dg;
        this.op_str = op_str;
    }


    /**
     * Evaluate this expression
     * Calls the evaluation delegate on both child expressions
     */

    public override double eval ( )
    {
        return this.eval_dg(this.left, this.right);
    }


    /**
     * Get the string representation of this expression
     */

    public override char[] str ( )
    {
        return format("(%s %s %s)", this.left.str, this.op_str, this.right.str);
    }
}


/**
 * Addition operator class
 */

public class Add : BinOp
{
    /**
     * Constructor
     */

    public this ( )
    {
        double plus(Exp left, Exp right)
        {
            return left.eval + right.eval;
        }

        super(&plus, cast(char[])"+");
    }
}


/**
 * Subtraction operator class
 */

public class Sub : BinOp
{
    /**
     * Constructor
     */

    public this ( )
    {
        double minus(Exp left, Exp right)
        {
            return left.eval - right.eval;
        }

        super(&minus, cast(char[])"-");
    }
}


/**
 * Multiplication operator class
 */

public class Multi : BinOp
{
    /**
     * Constructor
     */

    public this ( )
    {
        double multiply(Exp left, Exp right)
        {
            return left.eval * right.eval;
        }

        super(&multiply, cast(char[])"*");
    }
}


/**
 * Division operator class
 */

public class Div : BinOp
{
    /**
     * Constructor
     */

    public this ( )
    {
        double divide(Exp left, Exp right)
        in
        {
            assert(right.eval != 0, "Division by zero");
        }
        body
        {
            return left.eval / right.eval;
        }

        super(&divide, cast(char[])"/");
    }
}


/**
 * Power operator class
 *
 * Currently only supports positive integers in the exponent
 * Decimal numbers are rounded, negative numbers throw an error
 */

public class Pow : BinOp
{
    /**
     * Constructor
     */

    public this ( )
    {
        double power(Exp left, Exp right)
        in
        {
            assert(right.eval >= 0, "Negative exponent");
        }
        body
        {
            return this.power(left.eval, to!uint(right.eval));
        }

        super(&power, cast(char[])"^");
    }


    /**
     * Iterative power calculator function
     *
     * Params:
     *      num = The number
     *      exp = The exponent
     */

    private double power ( double num, uint exp )
    {
        if ( exp == 0 )
        {
            return 1;
        }

        double result = num;

        for ( uint i = 1; i < exp; i++ )
        {
            result *= num;
        }

        return result;;
    }
}


/**
 * Assignment expression class
 *
 * Asserts that the left expression is a variable on evaluation
 */

public class Assign : BinOp
{
    /**
     * Symbol table reference
     */

    private SymbolTable symtab;


    /**
     * Constructor
     */

    public this ( )
    {
        this.symtab = SymbolTable.instance;

        double assign(Exp var, Exp val)
        in
        {
            assert(cast(Var)var, "Left hand of assignment must be a variable");
        }
        body
        {
            this.symtab[var.str] = val;

            return val.eval;
        }

        super(&assign, cast(char[])"=");
    }
}