/**
 * Main program module
 */

module src.main.dmath;


/**
 * Imports
 */

private import src.mod.DMath;


/**
 * Main program function
 */

void main ( char[][] args )
{
    auto DMath = new DMath(args);
    DMath.run;
}