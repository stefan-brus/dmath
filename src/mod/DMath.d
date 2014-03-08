/**
 * Main logic module for DMath
 */

module src.mod.DMath;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.absyn.ExpressionBuilder;

private import src.core.parser.InputTokenizer;

private import src.core.parser.Parser;

private import src.core.util.app.Application;

private import src.core.util.File;

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
     * Set this flag to true if the app should quit
     */

    private bool quit;


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
     * Parse the given file
     * Treats each line as a dmath expression, evaluates it and returns the resulting expressions
     *
     * Params:
     *      file = The name of the file to parse
     *
     * Returns:
     *      The generated list of expressions
     */

    public Exp[] parseFile ( char[] file )
    {
        Exp[] result;
        auto lines = readLines(file);

        foreach ( str; lines )
        {
            result ~= this.eval(str);
        }

        return result;
    }


    /**
     * Evaluate a dmath expression string
     *
     * Params:
     *      str = The expression string
     *
     * Returns:
     *      The expression
     */

    public Exp eval ( char[] str )
    {
        auto tokens = tokenizer.parse(strip(str));

        if ( tokens.length == 1 && tokens[0].str == "quit" )
        {
            this.quit = true;
            return new Num(0);
        }
        else
        {

            auto post_queue = this.parser.parse(tokens);

            auto exp = this.exp_builder.buildExpression(post_queue);

            return exp;
        }
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
            auto expressions = this.parseFile(this.args.get(cast(char[])"-f"));

            foreach ( exp; expressions )
            {
                writefln("%s", exp.eval);
            }

            return false;
        }

        char[] input_buf;

        this.quit = false;

        if ( first_run )
        {
            writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");
        }

        while ( !this.quit )
        {
            writef("> ");
            stdin.readln(input_buf);

            auto exp = this.eval(input_buf);

            if ( this.quit )
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
        this.tokenizer.reset;
        this.parser.reset;
    }
}