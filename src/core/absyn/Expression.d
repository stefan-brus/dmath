/**
 * Contains the expression tree types
 */

module src.core.absyn.Expression;


/**
 * Imports
 */

private import src.core.absyn.util.Function;

private import src.core.symtab.SymbolTable;

private import std.conv;

private import std.string;


/**
 * Expression exception class
 */

public class ExpException : Exception
{
    /**
     * Constructor
     *
     * Params:
     *      msg = The error message
     */

    public this ( char[] msg )
    {
        super(cast(string)msg);
    }
}


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


    /**
     * Abstract function to copy this expression
     *
     * Returns:
     *      A copy of this expression
     */

    public abstract Exp copy ( );
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new Num(this.val);
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
     * Constructor
     *
     * Params:
     *      name = The variable name
     *      symtab = The symbol table reference
     */

    public this ( char[] name )
    {
        this.name = name;
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
        return SymbolTable.instance[name].exp.eval;
    }


    /**
     * Get the string representation of this expression
     */

    public override char[] str ( )
    {
        return this.name;
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new Var(this.name);
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


    /**
     * Helper method for copying a binary operator
     *
     * Template Params:
     *      T = The type of operator to create
     *
     * Returns:
     *      A new operator of the given type
     */

    protected T copy_op ( T ) ( )
    {
        T result = new T;
        result.left = this.left.copy;
        result.right = this.right.copy;
        return result;
    }
}


/**
 * Base function expression class
 *
 * Template Params:
 *      T = The argument list type
 */

public abstract class FnExp ( T ) : Exp
{
    /**
     * The function name
     */

    public char[] name;


    /**
     * Argument list
     */

    public T[] args;


    /**
     * Function expression
     */

    protected Exp exp;


    /**
     * Constructor
     *
     * Params:
     *      name = The function name
     *      args = The argument list
     */

    public this ( char[] name, T[] args )
    {
        this.name = name;
        this.args = args;
    }


    /**
     * Get the string representation of this expression
     */

    public override char[] str ( )
    {
        char[] result = format("%s(", this.name);

        foreach ( i, arg; this.args )
        {
            static if ( is(T : Exp) )
            {
                result ~= format("%s", arg.str);
            }
            else
            {
                result ~= format("%s", arg);
            }

            if ( i < this.args.length - 1 )
            {
                result ~=", ";
            }
        }

        result ~= ")";

        return result;
    }
}


/**
 * Function definition class
 */

public class FnDef : FnExp!(char[])
{
    /**
     * Constructor
     *
     * Params:
     *      name = The function name
     *      args = The argument list
     */

    public this ( char[] name, char[][] args )
    {
        super(name, args);
    }


    /**
     * Evaluate this expression
     * Throws an exception, because function definitions cannot be evaluated
     */

    public override double eval ( )
    {
        char[] msg = cast(char[])"Cannot evaluate function definition";
        throw new ExpException(msg);
        return 0;
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new FnDef(this.name, this.args);
    }
}
/**
 * Function definition argument class
 *
 * Contains the index of the argument
 */

public class FnArg : Var
{
    /**
     * The index of this argument
     */

    public uint idx;


    /**
     * Constructor
     *
     * Params:
     *      name = The argument name
     *      idx = The index of this argument
     */

    public this ( char[] name, uint idx )
    {
        super(name);
        this.idx = idx;
    }


    /**
     * Evaluate this expression
     *
     * Throws an exception, as this expression should have been replaced
     *
     * Returns:
     *      The value of the variable
     */

    public override double eval ( )
    {
        char[] msg = cast(char[])"Cannot evaluate function argument";
        throw new ExpException(msg);
        return 0;
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new FnArg(this.name, this.idx);
    }
}


/**
 * Function call class
 */

public class FnCall : FnExp!(Exp)
{
    /**
     * Constructor
     *
     * Params:
     *      name = The function name
     *      args = The argument list
     */

    public this ( char[] name, Exp[] args )
    {
        super(name, args);
    }


    /**
     * Evaluate this expression
     *
     * Calls the function with the argument list
     */

    public override double eval ( )
    {
        return FnUtil.instance.call(this.name, this.args).eval;
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new FnCall(this.name, this.args);
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Add;
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Sub;
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Multi;
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Div;
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


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Pow;
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
     * Constructor
     */

    public this ( )
    {
        double assign(Exp var, Exp val)
        in
        {
            assert(cast(Var)var || cast(FnDef)var, "Left hand of assignment must be a variable");
        }
        body
        {
            if ( cast(FnDef) var )
            {
                auto args = (cast(FnDef)var).args;
                auto replaced_exp = FnUtil.instance.replaceArgRefs(val, args);
                SymbolTable.instance.putFunction((cast(FnDef)var).name, val, args);

                return 0;
            }
            else
            {
                SymbolTable.instance[var.str] = val;

                return val.eval;
            }
        }

        super(&assign, cast(char[])"=");
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Assign;
    }
}