/**
 * Command generator module
 *
 * Initializes commands like save, load, and quit
 */

module dmath.runtime.Commands;


/**
 * Imports
 */

private import dmath.util.container.HashMap;

private import dmath.util.dmath.StateSaver;

private import dmath.util.dmath.StringEvaluator;

private import dmath.util.tmpl.Singleton;


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

    private HashMap!(string, CommandDg) comm_map;


    /**
     * State saver
     */

    private StateSaver saver;


    /**
     * Initialize the commands
     *
     * Params:
     *      evaluator = The string evaluator to pass to the saver
     *      saver = The state saver
     *      quit = The quit state of the running program, to be written by the quit command
     */

    public void initCommands ( StringEvaluator evaluator, StateSaver saver, out bool quit )
    {
        this.comm_map = new HashMap!(string, CommandDg);

        this.saver = saver;

        void commQuit ( )
        {
            quit = true;
        }

        void commSave ( )
        {
            this.saver.save;
        }

        void commLoad ( )
        {
            this.saver.load;
        }

        this.comm_map["quit"] = &commQuit;
        this.comm_map["save"] = &commSave;
        this.comm_map["load"] = &commLoad;
    }


    /**
     * Checks if the given string is a command
     *
     * Params:
     *      str = The string to check
     */

    public bool isCommand ( string str )
    {
        return str in this.comm_map;
    }


    /**
     * Execute the given command
     *
     * Params:
     *      str = The command to execute
     */

    public void exec ( string str )
    in
    {
        assert(this.isCommand(str), "Not a command: " ~ str);
    }
    body
    {
        this.comm_map[str]();
    }
}