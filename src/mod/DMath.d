/**
 * Main logic module for DMath
 */

module src.mod.DMath;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.parser.InputTokenizer;

private import src.core.parser.Parser;

private import std.stdio;

private import std.string;


/**
 * DMath main logic class
 */

public class DMath 
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
     * Constructor
     */

    public this ( )
    {
        this.tokenizer = new InputTokenizer;
        this.parser = new Parser;
    }


    /**
     * Main program logic function
     */
    public void run ( )
    {
        char[] input_buf;

        writefln("Welcome to DMath.\nEnter commands, or type 'quit' to quit.");

        while(strip(input_buf) != "quit")
        {
            writef("> ");
            stdin.readln(input_buf);

            auto tokens = tokenizer.parse(strip(input_buf));

            Exp exp = this.parser.parse(tokens);

            writefln("%s", exp.eval);
        }
    }
}