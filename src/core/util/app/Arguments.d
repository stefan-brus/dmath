/**
 * Module for handling command line arguments
 *
 * Parses a command line string with std.getopt and stores the arguments in a HashMap
 */

module src.core.util.app.Arguments;


/**
 * Imports
 */

private import src.core.util.container.HashMap;

private import std.getopt;


/**
 * Command line arguments class
 */

public class Arguments
{
    /**
     * Internal argument to value map
     */

    private HashMap!(string, string) arg_map;


    /**
     * Constructor
     *
     * Removes the application binary name from the argument string array
     *
     * Params:
     *      str_args = The array of string arguments
     *
     */

    public this ( string[] str_args )
    {
        this.arg_map = new HashMap!(string, string);

        if ( str_args.length > 1 )
        {
            this.setupArgs(str_args[1 .. $]);
        }
    }


    /**
     * Checks if a given argument is in the internal map
     *
     * Params:
     *      arg = The argument to check for
     *
     * Returns:
     *      True if the argument exists, false otherwise
     */

    public bool has ( string arg )
    {
        return arg in this.arg_map;
    }


    /**
     * Gets the value of the given argument
     *
     * Params:
     *      arg = The argument to get
     *
     * Returns:
     *      The value of the argument
     */

    public string get ( string arg )
    in
    {
        assert(arg in this.arg_map, "Argument does not exist");
    }
    body
    {
        return this.arg_map[arg];
    }


    /**
     * Sets up the argument map
     * Goues through pairs of strings in the string argument array
     *
     * Params:
     *      str_args = The array of string arguments
     */

    private void setupArgs( string[] str_args )
    {
        for ( int i = 0; i < str_args.length - 1; i += 2 )
        {
            arg_map[str_args[i]] = str_args[i + 1];
        }
    }
}


/**
 * Unittests
 */

unittest
{
    /**
     * Error message
     */

    const err_msg = "Arguments unittests failed";


    /**
     * Arguments tests
     */

    string[] str_args = [ "dmath", "-arg1", "val1", "-arg2", "val2" ];
    auto args = new Arguments(str_args);
    assert(args.has("-arg1"), err_msg);
    assert(args.has("-arg2"), err_msg);
    assert(!args.has("-arg3"), err_msg);
    assert(args.get("-arg1") == "val1", err_msg);
    assert(args.get("-arg2") == "val2", err_msg);
}