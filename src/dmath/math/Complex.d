/**
 * Mathematical operations on complex numbers
 *
 * Uses dmath.absyn.Expression.ComplexVal structs
 *
 * Formulas used:
 *
 * Argument
 * arg(x + yi) = atan(y / x)
 *
 * Addition
 * (x + yi) + (u + vi) = (x + u) + (y + v)i
 *
 * Subtraction
 * (x + yi) - (u + vi) = (x - u) + (y - v)i
 *
 * Multiplication
 * (x + yi) * (u + vi) = xu + xvi + yui + yvi^2 = (xu - yv) + (xv + yu)i
 *
 * Division
 * (x + yi) / (u + vi) = ((x + yi) * (u - vi)) / ((u + vi) * (u - vi)) =
 * ((xu + yv) / (u^2 + v^2)) + ((yu - xv) / (u^2 + v^2))i
 *
 * Power (HOLY FUCK)
 * Just read about it here: http://mathworld.wolfram.com/ComplexExponentiation.html
 *
 * TODO: Complex argument of numbers with a real component of 0
 */

module dmath.math.Complex;


/**
 * Imports
 */

private import dmath.absyn.Expression;

private import dmath.math.Logarithm;

private import dmath.math.Math;

private import dmath.math.Trigonometry;

private import dmath.util.tmpl.Singleton;


/**
 * Complex functions class
 *
 * Implemented as a singleton
 */

public class ComplexUtil : Singleton!(ComplexUtil)
{
    /**
     * i
     */

    public static const ComplexVal I = ComplexVal(0, 1);


    /**
     * Get the argument of a complex number
     *
     * Params:
     *      c = The complex number
     *
     * Returns:
     *      arg(c)
     */

    public double arg ( ComplexVal c )
    {
        if ( c.real_val == 0 )
        {
            throw new ExpException("Complex argument: real value is zero");
        }

        return TrigUtil().atan2(c.imag_val, c.real_val);
    }

    /**
     * Add two complex numbers
     *
     * Params:
     *      c1 = The first complex number
     *      c2 = The second complex number
     *
     * Returns:
     *      c1 + c2
     */

    public ComplexVal add ( ComplexVal c1, ComplexVal c2 )
    {
        return ComplexVal(c1.real_val + c2.real_val, c1.imag_val + c2.imag_val);
    }


    /**
     * Subtract two complex numbers
     *
     * Params:
     *      c1 = The first complex number
     *      c2 = The second complex number
     *
     * Returns:
     *      c1 - c2
     */

    public ComplexVal sub ( ComplexVal c1, ComplexVal c2 )
    {
        return ComplexVal(c1.real_val - c2.real_val, c1.imag_val - c2.imag_val);
    }


    /**
     * Multiply two complex numbers
     *
     * Params:
     *      c1 = The first complex number
     *      c2 = The second complex number
     *
     * Returns:
     *      c1 * c2
     */

    public ComplexVal multiply ( ComplexVal c1, ComplexVal c2 )
    {
        ComplexVal result;

        auto x = c1.real_val, y = c1.imag_val, u = c2.real_val, v = c2.imag_val;

        result.real_val = (x * u) - (y * v);
        result.imag_val = (x * v) + (y * u);

        return result;
    }


    /**
     * Divide two complex numbers
     *
     * Params:
     *      c1 = The first complex number
     *      c2 = The second complex number
     *
     * Returns:
     *      c1 / c2
     *
     * Throws:
     *      ExpException if division by zero
     */

    public ComplexVal divide ( ComplexVal c1, ComplexVal c2 )
    {
        ComplexVal result;

        auto x = c1.real_val, y = c1.imag_val, u = c2.real_val, v = c2.imag_val;

        if ( (u * u) + (v * v) == 0 )
        {
            throw new ExpException("Division by zero");
        }

        result.real_val = ((x * u) + (y * v)) / ((u * u) + (v * v));
        result.imag_val = ((y * u) - (x * v)) / ((u * u) + (v * v));

        return result;
    }


    /**
     * Calculate the one complex number to the power of another
     *
     * Params:
     *      c1 = The base
     *      c2 = The exponent
     *
     * Returns:
     *      c1 ^ c2
     */

    public ComplexVal pow ( ComplexVal c1, ComplexVal c2 )
    {
        double a = c1.real_val, b = c1.imag_val, c = c2.real_val, d = c2.imag_val;

        double term = (c * this.arg(c1)) + ((d / 2) * LogUtil().ln(a * a + b * b));

        ComplexVal factor = ComplexVal(MathUtil().pow(a * a + b * b, cast(int)(c / 2)) * MathUtil().pow(MathUtil.E, cast(int)(-d * this.arg(c1))), 0);

        ComplexVal real_term = ComplexVal(TrigUtil().cos(term), 0);

        ComplexVal imag_term = this.multiply(I, ComplexVal(TrigUtil().sin(term), 0));

        return this.add(this.multiply(factor, real_term), this.multiply(factor, imag_term));
    }
}