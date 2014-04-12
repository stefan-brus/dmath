/**
 * Contains the expression tree types
 */

module dmath.absyn.Expression;


/**
 * Imports
 */

private import dmath.absyn.util.Function;

private import dmath.math.Complex;

private import dmath.math.Math;

private import dmath.symtab.SymbolTable;

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

    public this ( string msg )
    {
        super(msg);
    }
}


/**
 * Complex value type
 */

public struct ComplexVal
{
    double real_val = 0;
    double imag_val = 0;

    string str ( )
    {
        return format("{%s, %si}", this.real_val, this.imag_val);
    }
}


/**
 * The different types an expression can evaluate to
 */

public union ValType
{
    /**
     * Real value
     */

    double val;


    /**
     * Complex value
     */

    ComplexVal complex;
}


/**
 * The actual type of the expression
 */

public enum Type
{
    Invalid = 0,
    Real = 1,
    Complex = 2
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
     * The type of this expression
     */

    public Type type = Type.Real;


    /**
     * Abstract function to evaluate this expression
     */

    public abstract ValType eval ( );


    /**
     * Abstract function to get the string of this expression
     *
     * Returns:
     *      The string of this expression's value, and its children's string representations
     */

    public abstract string str ( );


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

    private ValType val;


    /**
     * Constructor
     *
     * Params:
     *      val = The numeric value
     */

    public this ( double val )
    {
       this.val = ValType(val);
    }


    /**
     * Evaluate this expression
     * Returns the numeric value
     */

    public override ValType eval ( )
    {
        return this.val;
    }


    /**
     * Get the string representation of this expression
     */

    public override string str ( )
    {
        return format("%s", this.val.val);
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return new Num(this.val.val);
    }
}


/**
 * Complex number expression class
 *
 * "left" is the real value, "right" is the imaginary value
 */

public class Complex : Exp
{
    /**
     * Constructor
     */

    public this ( )
    {
        this.type = Type.Complex;
    }


    /**
     * Evaluate this expression
     *
     * Returns a complex value
     */

    public override ValType eval ( )
    {
        if ( left.type == Type.Complex || right.type == Type.Complex )
        {
            throw new ExpException("Complex number cannot have complex components");
        }

        return cast(ValType)ComplexVal(this.left.eval.val, this.right.eval.val);
    }


    /**
     * Get the string representation of this expression
     */

    public override string str ( )
    {
        return format("{%s, %si}", left.str, right.str);
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        auto result = new Complex;
        result.left = this.left.copy;
        result.right = this.right.copy;
        return result;
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

    private string name;


    /**
     * Constructor
     *
     * Params:
     *      name = The variable name
     *      symtab = The symbol table reference
     */

    public this ( string name )
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

    public override ValType eval ( )
    {
        return SymbolTable.instance[name].exp.eval;
    }


    /**
     * Get the string representation of this expression
     */

    public override string str ( )
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
     * Complex operation evaluation delegate
     * Call a function on both child expressions
     */

    private alias ComplexVal delegate(Exp, Exp) ComplexOpDg;


    /**
     * Child expression evaluators
     */

    private BinOpDg eval_dg;

    private ComplexOpDg complex_dg;


    /**
     * The string representation of this operator
     */

    private string op_str;


    /**
     * Constructor
     *
     * Params:
     *      eval_dg = Child expression evaluator delegate
     *      complex_dg = Complex expression evaluator delegate
     *      op_str = The string representation of this operator
     */

    public this ( BinOpDg eval_dg, ComplexOpDg complex_dg, string op_str )
    {
        this.eval_dg = eval_dg;
        this.complex_dg = complex_dg;
        this.op_str = op_str;
    }


    /**
     * Evaluate this expression
     * Calls the evaluation delegate on both child expressions
     */

    public override ValType eval ( )
    {
        ValType result;

        if ( this.type == Type.Real )
        {
            result = cast(ValType)this.eval_dg(left, right);
        }
        else if ( this.type == Type.Complex )
        {
            result = cast(ValType)this.complex_dg(left, right);
        }

        return result;
    }


    /**
     * Get the string representation of this expression
     */

    public override string str ( )
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

    public string name;


    /**
     * Argument list
     */

    public T[] args;


    /**
     * Constructor
     *
     * Params:
     *      name = The function name
     *      args = The argument list
     */

    public this ( string name, T[] args )
    {
        this.name = name;
        this.args = args;
    }


    /**
     * Get the string representation of this expression
     */

    public override string str ( )
    {
        auto result = format("%s(", this.name);

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

public class FnDef : FnExp!(string)
{
    /**
     * Constructor
     *
     * Params:
     *      name = The function name
     *      args = The argument list
     */

    public this ( string name, string[] args )
    {
        super(name, args);
    }


    /**
     * Evaluate this expression
     * Throws an exception, because function definitions cannot be evaluated
     */

    public override ValType eval ( )
    {
        auto msg = "Cannot evaluate function definition";
        throw new ExpException(msg);
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

    public this ( string name, uint idx )
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

    public override ValType eval ( )
    {
        auto msg = "Cannot evaluate function argument";
        throw new ExpException(msg);
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

    public this ( string name, Exp[] args )
    {
        super(name, args);
    }


    /**
     * Evaluate this expression
     *
     * Calls the function with the argument list
     */

    public override ValType eval ( )
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
            return left.eval.val + right.eval.val;
        }

        ComplexVal complex(Exp left, Exp right)
        {
            return ComplexUtil.instance.add(left.eval.complex, right.eval.complex);
        }

        super(&plus, &complex, "+");
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
            return left.eval.val - right.eval.val;
        }

        ComplexVal complex(Exp left, Exp right)
        {
            return ComplexUtil.instance.sub(left.eval.complex, right.eval.complex);
        }

        super(&minus, &complex, "-");
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
            return left.eval.val * right.eval.val;
        }

        ComplexVal complex(Exp left, Exp right)
        {
            return ComplexUtil.instance.multiply(left.eval.complex, right.eval.complex);
        }

        super(&multiply, &complex, "*");
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
        {
            if ( right.eval.val == 0 )
            {
                throw new ExpException("Division by zero");
            }

            return left.eval.val / right.eval.val;
        }

        ComplexVal complex(Exp left, Exp right)
        {
            return ComplexUtil.instance.divide(left.eval.complex, right.eval.complex);
        }

        super(&divide, &complex, "/");
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
        {
            return MathUtil.instance.pow(left.eval.val, to!uint(right.eval.val));
        }

        ComplexVal complex(Exp left, Exp right)
        {
            return ComplexUtil.instance.pow(left.eval.complex, right.eval.complex);
        }

        super(&power, &complex, "^");
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
        {
            if ( !(cast(Var)var || cast(FnDef)var) )
            {
                throw new ExpException("Left hand of assignment must be a variable or function definition");
            }

            if ( cast(FnDef) var )
            {
                auto args = (cast(FnDef)var).args;
                FnUtil.instance.putFunction((cast(FnDef)var).name, val, args);

                return 0;
            }
            else
            {
                SymbolTable.instance[var.str] = val;

                return val.eval.val;
            }
        }

        ComplexVal complex(Exp var, Exp val)
        {
            assign(var, val);

            if ( cast(FnDef) var )
            {
                return ComplexVal(0, 0);
            }
            else
            {
                return val.eval.complex;
            }
        }

        super(&assign, &complex, "=");
    }


    /**
     * Copy this expression
     */

    public override Exp copy ( )
    {
        return super.copy_op!Assign;
    }
}