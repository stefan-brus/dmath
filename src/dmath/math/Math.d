/**
 * General math functions
 *
 * TODO: Handle negative exponents and decimal exponents
 */

module dmath.math.Math;


/**
 * Imports
 */

private import dmath.util.tmpl.Singleton;

private import std.math: approxEqual;


/**
 * Math exception class
 */

public class MathException : Exception
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
 * General math functions class
 *
 * Implemented as a singleton
 */

public class MathUtil : Singleton!(MathUtil)
{
    /**
     * The precision for the "infinite" Taylor series used to calculate various things
     */

    private static const PRECISION = 15;


    /**
     * Pi
     */

    public static const PI = 3.14159265359;


    /**
     * e
     */

    public static const E = 2.71828182845;


    /**
     * Get the absolute value of a number
     *
     * Ex: abs(-2) == 2
     *
     * Params:
     *      num = The number to get the absolute value of
     *
     * Returns:
     *      The absolute value of the given number
     */

    public double abs ( double num )
    {
        if ( num < 0 )
        {
            return num * -1;
        }
        else
        {
            return num;
        }
    }


    /**
     * Iterative power calculator function
     *
     * Params:
     *      num = The number
     *      exp = The exponent
     *
     * Returns:
     *      num ^ exp
     *
     * TODO: Handle negative exponents and decimal exponents
     */

    public double pow ( double num, int exp )
    {
        if ( exp < 0 )
        {
            throw new MathException("Negative exponent");
        }

        if ( exp == 0 )
        {
            return 1;
        }

        double result = num;

        for ( uint i = 1; i < exp; i++ )
        {
            result *= num;
        }

        return result;
    }


    /**
     * Iterative factorial calculator function
     *
     * Params:
     *      num = The number
     *
     * Returns:
     *      num!
     */

    public double fac ( uint num )
    {
        double result = num == 0 ? 1 : num;

        for ( uint i = 2; i < num; i++ )
        {
            result *= i;
        }

        return result;
    }


    /**
     * Square root function
     *
     * Basically guesses the root until a good enough estimate is found
     *
     * The precision is calculated with black magic
     *
     * The initial guess, too
     *
     * Params:
     *      num = The number to get the square root of
     *
     * Returns:
     *      The square root of the given number
     *
     * TODO: Handle negative numbers, should return complex value
     */

    public double sqrt ( double num )
    {
        double guess = 1;

        while ( !approxEqual(guess * guess, num) )
        {
            guess = (guess + (num / guess)) / 2;
        }

        return guess;
    }


        /*
          def sqrt(x: Double): Double = {
            def sqrtIter(guess: Double): Double = {
              def isGoodEnough(guess: Double): Boolean =
                abs(guess * guess - x) / x < 0.001

              def improve(guess: Double): Double =
                (guess + x / guess) / 2

              if (isGoodEnough(guess)) guess
              else sqrtIter(improve(guess))
            }
            sqrtIter(1.0)
          } */


    /**
     * Get the number of digits in a number
     *
     * Params:
     *      num = The number
     *
     * Returns:
     *      The number of digits in num
     *
     * TODO: Handle different bases?
     */

    public uint digits ( double num )
    {
        uint result = 1;

        num /= 10;

        while ( num >= 1 )
        {
            result++;
            num /= 10;
        }

        return result;
    }
}