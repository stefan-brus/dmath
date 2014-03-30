/**
 * Main logic module for DMath
 */

module src.mod.DMath;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.runtime.Commands;

private import src.core.runtime.Constants;

private import src.core.util.app.Application;

private import src.core.util.dmath.FileParser;

private import src.core.util.dmath.StateSaver;

private import src.core.util.dmath.StringEvaluator;

private import src.core.util.Array;

private import std.stdio;

private import std.string;


/**
 * DMath main logic class
 */

public class DMath : Application
{
    /**
     * The file to save and load the state to/from
     */

    private static const string STATE_FILE = "state.json";


    /**
     * File parser
     */

    private FileParser file_parser;


    /**
     * String evaluator
     */

    private StringEvaluator evaluator;


    /**
     * State saver
     */

    private StateSaver saver;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments
     */

    public this ( string[] str_args )
    {
        super(str_args);
        this.file_parser = new FileParser;
        this.evaluator = new StringEvaluator;
    }


    /**
     * Process the command line arguments
     *
     * Arguments:
     *      -s = Load the state from a file
     *      -f = Read expressions from a file
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected override bool processArgs ( )
    {
        // Load the state from a file
        if ( this.args.has("-s") )
        {
            auto file_name = this.args.get("-s");

            this.saver = new StateSaver(this.evaluator, file_name);

            try
            {
                this.saver.load;
            }
            catch ( Exception e )
            {
                writefln("Unable to read file: %s, reason: %s", file_name, e.msg);
            }
        }
        else
        {
            this.saver = new StateSaver(this.evaluator, STATE_FILE);
        }

        // Evaluate expressions in a given file
        if ( this.args.has("-f") )
        {
            auto file_name = this.args.get("-f");

            try
            {
                auto expressions = this.file_parser.parseFile(this.args.get("-f"));

                foreach ( exp; expressions )
                {
                    writefln("%s", exp.eval);
                }
            }
            catch ( Exception e )
            {
                writefln("Unable to parse file: %s, reason: %s", file_name, e.msg);
                return false;
            }

            return false;
        }

        return true;
    }


    /**
     * Main program logic function
     *
     * Initializes constants
     * Handles command line arguments
     * If the tokenizer only contains one word, and it is a command
     * this class will execute the command
     *
     * Params:
     *      first_run = If this is the first run of the program
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected override bool appMain ( bool first_run )
    {
        Constants.instance.initConstants;

        if ( !this.processArgs )
        {
            return false;
        }

        char[] input_buf;

        bool quit = false;

        Exp exp;

        Commands.instance.initCommands(this.evaluator, this.saver, quit);

        if ( first_run )
        {
            writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");
        }

        while ( !quit )
        {
            writef("> ");
            stdin.readln(input_buf);

            if ( Commands.instance.isCommand(cast(string)strip(input_buf)) )
            {
                Commands.instance.exec(cast(string)strip(input_buf));
            }
            else
            {
                exp = this.evaluator.eval(cast(string)input_buf);
                writefln("%s", exp.eval);
            }

            if ( quit )
            {
                return false;
            }
        }

        return true;
    }


    /**
     * Resets the state of this program
     */

    protected override void reset ( )
    {
        this.file_parser.reset;
    }
}