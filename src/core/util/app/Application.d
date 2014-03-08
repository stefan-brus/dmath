/**
 * Command line application base class
 *
 * Takes care of argument parsing and error handling
 */

module src.core.util.app.Application;


/**
 * Imports
 */

private import src.core.util.app.Arguments;

private import std.stdio;


/**
 * Application base class
 */

public abstract class Application
{
    /**
     * Command line arguments
     */

    protected Arguments args;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments as received by main
     */

    public this ( char[][] str_args )
    {
        this.args = new Arguments(str_args);
    }


    /**
     * Run the application
     *
     * Deals with exception handling
     */

    public void run ( )
    {
        bool running = true;
        bool first_run = true;

        while ( running )
        {
            try
            {
                running = this.appMain(first_run);
            }
            catch ( Exception e )
            {
                writefln("Error: %s", e.msg);
            }
            finally
            {
                this.reset;
                first_run = false;
            }
        }
    }


    /**
     * Main application logic method, override this
     *
     * Params:
     *      first_run = If this is the first run of the program
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected abstract bool appMain ( bool first_run );


    /**
     * Application reset method, override this
     */

    protected abstract void reset ( );
}