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

private import src.core.util.dmath.StateSaver;

private import src.core.util.dmath.StringEvaluator;

private import src.core.util.tmpl.Singleton;


/**
 * Commands class
 *
 * Implemented as a singleton
 */

public class Commands : Singleton!(Commands)
{
    /**
     * The file to save and load the state to/from
     */

    private static const char[] STATE_FILE = "state.json";


    /**
     * Command execution delegate aliass
     */

    private alias void delegate ( ) CommandDg;


    /**
     * Map of commands
     */

    private HashMap!(char[], CommandDg) comm_map;


    /**
     * State saver
     */

    private StateSaver saver;


    /**
     * Initialize the commands
     *
     * Params:
     *      evaluator = The string evaluator to pass to the saver
     *      quit = The quit state of the running program, to be written by the quit command
     */

    public void initCommands ( StringEvaluator evaluator, out bool quit )
    {
        this.comm_map = new HashMap!(char[], CommandDg);

        this.saver = new StateSaver(evaluator, cast(char[])STATE_FILE);

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

        this.comm_map[cast(char[])"quit"] = &commQuit;
        this.comm_map[cast(char[])"save"] = &commSave;
        this.comm_map[cast(char[])"load"] = &commLoad;
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