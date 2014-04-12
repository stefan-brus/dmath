/**
 * Logarithmic functions
 *
 * See http://en.wikipedia.org/wiki/Natural_logarithm#Numerical_value
 * For formulaic implementation details
 *
 * TODO: Handle negative numbers (should return complex values)
 */

module dmath.math.Logarithm;


/**
 * Imports
 */

private import dmath.math.Math;

private import dmath.util.tmpl.Singleton;


/**
 * Logarithm functions class
 *
 * Implemented as a singleton
 */

public class LogUtil : Singleton!(LogUtil)
{
    /**
     * The precision for the "infinite" Taylor series used to calculate various logarithmic functions
     */

    private static const PRECISION = 10;


    /**
     * The value of the expression ln(10), for faster calculation
     */

    private static const LN10 = 2.3025851;


    /**
     * Calculate the natural logarithm of the given number
     *
     * Params:
     *      num = The number
     *
     * Returns:
     *      ln num
     *
     * TODO: Handle negative numbers
     */

    public double ln ( double num )
    {
        if ( num < 0 )
        {
            throw new MathException("Logarithm of negative numbers not implemented");
        }

        if ( num == 0 )
        {
            throw new MathException("Logartihm of 0");
        }

        auto digits = MathUtil().digits(num);

        num /= MathUtil().pow(10.0, digits - 1);

        double y = (num - 1) / (num + 1);

        double result = 0;

        for ( uint i = 0; i < PRECISION; i++ )
        {
            auto pow_factor = i * 2;
            auto div_factor = i * 2 + 1;

            result += MathUtil().pow(y, pow_factor) / div_factor;
        }

        result *= 2 * y;

        if ( digits > 1 )
        {
            result += (digits - 1) * LN10;
        }

        return result;
    }
}