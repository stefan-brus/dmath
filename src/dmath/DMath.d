/**
 * Main logic module for DMath
 */

module dmath.DMath;


/**
 * Imports
 */

private import dmath.absyn.util.Type;

private import dmath.absyn.Expression;

private import dmath.runtime.Commands;

private import dmath.runtime.Constants;

private import dmath.util.app.Application;

private import dmath.util.dmath.FileParser;

private import dmath.util.dmath.StateSaver;

private import dmath.util.dmath.StringEvaluator;

private import dmath.util.Array;

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
                    this.printExp(TypeUtil.instance.infer(exp));
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

                this.printExp(exp);
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


    /**
     * Print the given expression
     *
     * Params:
     *      exp = The expression to print
     */

    private void printExp ( Exp exp )
    {
        with ( Type ) switch ( exp.type )
        {
            case Real:
                writefln("%s", exp.eval.val);
                break;
            case Complex:
                auto val = exp.eval.complex;

                if ( val.imag_val == 0 )
                {
                    writefln("%s", exp.eval.val);
                }
                else
                {
                    writefln("%s", exp.eval.complex.str);
                }

                break;
            default:
                assert(false, "Unknown expression type");
        }
    }
}


/**
 * Main function
 */

void main ( string[] args )
{
    auto dmath = new DMath(args);
    dmath.run;
}