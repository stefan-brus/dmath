/**
 * Contains the expression tree types
 */

module src.core.absyn.Expression;


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
     * Constructor
     *
     * Params:
     *      eval_dg = Child expression evaluator delegate
     */

    public this ( BinOpDg eval_dg )
    {
        this.eval_dg = eval_dg;
    }


    /**
     * Evaluate this expression
     * Calls the evaluation delegate on both child expressions
     */

    public override double eval ( )
    {
        return this.eval_dg(this.left, this.right);
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

        super(&plus);
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

        super(&minus);
    }
}