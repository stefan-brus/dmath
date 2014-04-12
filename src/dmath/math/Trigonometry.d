/**
 * Trigonometry functions
 *
 * Formulas used:
 *
 * sin x = x - x^3/3! + x^5/5! - x^7/7! + ...
 *
 * cos x = sqrt(1 - (sin x)^2)
 *
 * tan x = sin x / cos x
 *
 * atan x = x - x^3/3 + x^5/5 - x^7/7 + ...
 *
 * atan2 x = http://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent
 *
 * rad x = x % pi
 */

module dmath.math.Trigonometry;


/**
 * Imports
 */

private import dmath.math.Math;

private import dmath.util.tmpl.Singleton;


/**
 * Trigonometry functions class
 *
 * Implemented as a singleton
 */

public class TrigUtil : Singleton!(TrigUtil)
{
    /**
     * The precision for the "infinite" Taylor series used to calculate various trigonometric functions
     */

    private static const PRECISION = 15;


    /**
     * Calculate the sine of a number
     *
     * Params:
     *      num = The number to get the sine of
     *
     * Returns:
     *      The sine of the given number
     */

    public double sin ( double num )
    out ( sine )
    {
        assert(sine >= -1 && sine <= 1, "Sine out of range");
    }
    body
    {
        double result = 0;

        double rad = this.toRadians(num);

        for ( uint i = 0; i < PRECISION * 2; i += 2 )
        {
            int plus_factor = i * 2 + 1;
            int minus_factor = (i + 1) * 2 + 1;

            result += MathUtil.instance.pow(rad, plus_factor) / MathUtil.instance.fac(plus_factor);
            result -= MathUtil.instance.pow(rad, minus_factor) / MathUtil.instance.fac(minus_factor);
        }

        return result;
    }


    /**
     * Calculate the cosine of a number
     *
     * Params:
     *      num = THe number to get the cosine of
     *
     * Returns:
     *      The cosine of the given number
     */

    public double cos ( double num )
    out ( cosine )
    {
        assert(cosine >= 0 && cosine <= 1, "Cosine out of range");
    }
    body
    {
        return MathUtil.instance.sqrt(1 - MathUtil.instance.pow(this.sin(num), 2));
    }


    /**
     * Calculate the tangent of a number
     *
     * Params:
     *      num = The number to get the tangent of
     *
     * Returns:
     *      The tangent of the given number
     */

    public double tan ( double num )
    {
        if ( this.cos(num) == 0 )
        {
            throw new MathException("Tangent: Cosine is zero");
        }

        return this.sin(num) / this.cos(num);
    }


    /**
     * Calculate the arctangent of a number
     *
     * Params:
     *      num = The number to get the arctangent of
     *
     * Returns:
     *      The arctangent of the given number
     */

    public double atan ( double num )
    {
        if ( num > 1 )
        {
            return (MathUtil.PI / 2) - this.atan(1/num);
        }
        else
        {
            double result = 0;

            num = MathUtil.instance.abs(num);
            num %= MathUtil.PI / 2;

            for ( uint i = 0; i < PRECISION * 2; i += 2 )
            {
                auto plus_factor = i * 2 + 1;
                auto minus_factor = (i + 1) * 2 + 1;

                result += MathUtil.instance.pow(num, plus_factor) / plus_factor;
                result -= MathUtil.instance.pow(num, minus_factor) / minus_factor;
            }

            return result;
        }
    }


    /**
     * Two-argument arctan function
     *
     * Params:
     *      y = The y coordinate
     *      x = The x coordinate
     *
     * Returns:
     *      atan2(y, x)
     */

    public double atan2 ( double y, double x )
    out ( res )
    {
        assert(res >= -MathUtil.PI / 2 && res <= MathUtil.PI / 2, "arctangent out of range");
    }
    body
    {
        if ( x > 0 )
        {
            return this.atan(y / x);
        }
        else if ( x < 0 )
        {
            if ( y >= 0 )
            {
                return MathUtil.PI + this.atan(y / x);
            }
            else
            {
                return -MathUtil.PI + this.atan(y / x);
            }
        }
        else
        {
            if ( y > 0 )
            {
                return MathUtil.PI / 2;
            }
            else if ( y < 0 )
            {
                return -MathUtil.PI / 2;
            }
            else
            {
                throw new MathException("atan2(0, 0) is undefined");
            }
        }
    }


    /**
     * Convert a number to radians
     *
     * Params:
     *      num = The number to convert
     *
     * Returns:
     *      The number in radians
     */

    public double toRadians ( double num )
    out ( rad )
    {
        assert(rad >= -MathUtil.PI && rad <= MathUtil.PI, "Radian out of range");
    }
    body
    {
        auto abs = MathUtil.instance.abs(num);

        return num % MathUtil.PI;
    }
}