/**
 * Test suite program module
 */

module src.main.test;


/**
 * Imports
 */

private import src.mod.Test;


/**
 * Main program function
 */

void main ( char[][] args )
{
    auto Test = new Test(args);
    Test.run;
}