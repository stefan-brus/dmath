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

void main ( )
{
    auto DMath = new DMath;

    bool running = true;
    bool first_run = true;

    while ( running )
    {
        try
        {
            running = DMath.run(first_run);
        }
        catch ( Exception e )
        {
            writefln("Error: %s", e.msg);
        }
        finally
        {
            DMath.reset;
            first_run = false;
        }
    }
}