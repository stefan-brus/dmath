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
     * File parser
     */

    private FileParser file_parser;


    /**
     * String evaluator
     */

    private StringEvaluator evaluator;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments
     */

    public this ( char[][] str_args )
    {
        super(str_args);
        this.file_parser = new FileParser;
        this.evaluator = new StringEvaluator;
    }


    /**
     * Main program logic function
     *
     * Initializes constants
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

        if ( this.args.has(cast(char[])"-f") )
        {
            auto expressions = this.file_parser.parseFile(this.args.get(cast(char[])"-f"));

            foreach ( exp; expressions )
            {
                writefln("%s", exp.eval);
            }

            return false;
        }

        char[] input_buf;

        bool quit = false;

        Exp exp;

        Commands.instance.initCommands(quit);

        if ( first_run )
        {
            writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");
        }

        while ( !quit )
        {
            this.evaluator.reset;

            writef("> ");
            stdin.readln(input_buf);

            if ( Commands.instance.isCommand(strip(input_buf)) )
            {
                Commands.instance.exec(strip(input_buf));
            }
            else
            {
                exp = this.evaluator.eval(input_buf);
            }

            if ( quit )
            {
                return false;
            }
            else
            {
                writefln("%s", exp.eval);
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
        this.evaluator.reset;
    }
}