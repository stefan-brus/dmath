/**
 * Main logic module for DMath
 */

module src.mod.DMath;


/**
 * Imports
 */

private import src.core.absyn.ExpressionBuilder;

private import src.core.parser.InputTokenizer;

private import src.core.parser.Parser;

private import src.core.util.app.Application;

private import std.stdio;

private import std.string;


/**
 * DMath main logic class
 */

public class DMath : Application
{

    /**
     * Input tokenizer
     */

    private InputTokenizer tokenizer;


    /**
     * Parser
     */

    private Parser parser;


    /**
     * Expression builder
     */

    private ExpressionBuilder exp_builder;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments
     */

    public this ( char[][] str_args )
    {
        super(str_args);
        this.tokenizer = new InputTokenizer;
        this.parser = new Parser;
        this.exp_builder = new ExpressionBuilder;
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
        char[] input_buf;

        if ( first_run )
        {
            writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");
        }

        while(strip(input_buf) != "quit")
        {
            writef("> ");
            stdin.readln(input_buf);

            auto tokens = tokenizer.parse(strip(input_buf));

            if ( tokens.length == 1 && tokens[0].str == "quit" )
            {
                return false;
            }

            auto post_queue = this.parser.parse(tokens);

            auto exp = this.exp_builder.buildExpression(post_queue);

            writefln("%s", exp.eval);
        }

        return true;
    }


    /**
     * Resets the state of this program
     */

    protected override void reset ( )
    {
        this.tokenizer.reset;
        this.parser.reset;
    }
}