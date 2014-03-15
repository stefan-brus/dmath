/**
 * Command generator module
 *
 * Initializes commands like save, load, and quit
 */

module src.core.runtime.Commands;


/**
 * Imports
 */

private import src.core.util.container.HashMap;

private import src.core.util.tmpl.Singleton;


/**
 * Commands class
 *
 * Implemented as a singleton
 */

public class Commands : Singleton!(Commands)
{
    /**
     * Command execution delegate aliass
     */

    private alias void delegate ( ) CommandDg;


    /**
     * Map of commands
     */

    private HashMap!(char[], CommandDg) comm_map;


    /**
     * Initialize the commands
     *
     * Params:
     *      quit = The quit state of the running program, to be written by the quit command
     */

    public void initCommands ( out bool quit )
    {
        this.comm_map = new HashMap!(char[], CommandDg);

        void commQuit ( )
        {
            quit = true;
        }

        this.comm_map[cast(char[])"quit"] = &commQuit;
    }


    /**
     * Checks if the given string is a command
     *
     * Params:
     *      str = The string to check
     */

    public bool isCommand ( char[] str )
    {
        return str in this.comm_map;
    }


    /**
     * Execute the given command
     *
     * Params:
     *      str = The command to execute
     */

    public void exec ( char[] str )
    in
    {
        assert(this.isCommand(str), "Not a command: " ~ str);
    }
    body
    {
        this.comm_map[str]();
    }
}