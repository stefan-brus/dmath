/**
 * Main logic module for DMath
 */

module src.mod.DMath;


/**
 * Imports
 */

private import src.core.util.app.Application;

private import src.mod.common.FileParser;

private import src.mod.common.StringEvaluator;

private import std.stdio;


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
     * If the tokenizer only returns one token, and it is a string
     * This class will try to handle it as a command
     *
     * Params:
     *      first_run = If this is the first run of the program
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected override bool appMain ( bool first_run )
    {
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

        if ( first_run )
        {
            writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");
        }

        while ( !quit )
        {
            writef("> ");
            stdin.readln(input_buf);

            auto exp = this.evaluator.eval(input_buf, quit);

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