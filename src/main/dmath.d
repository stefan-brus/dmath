/**
 * Main program module
 */

module src.main.dmath;


/**
 * Imports
 */

private import src.mod.DMath;

private import std.stdio;


/**
 * Main program function
 *
 * Handles exceptions by displaying the error message and re-running DMath
 * Exits if the 'run' method returns false
 */

void main ( char[][] args )
{
    auto DMath = new DMath(args);
    DMath.run;
}