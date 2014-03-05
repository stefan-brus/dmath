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
     *
     * If the tokenizer only returns one token, and it is a string
     * This class will try to handle it as a command
     */
    public void run ( )
    {
        char[] input_buf;

        writefln("Welcome to DMath.\nEnter expressions, or type 'quit' to quit.");

        while(strip(input_buf) != "quit")
        {
            writef("> ");
            stdin.readln(input_buf);

            auto tokens = tokenizer.parse(strip(input_buf));

            if ( tokens.length == 1 && tokens[0].str == "quit" )
            {
                return;
            }

            Exp exp = this.parser.parse(tokens);

            writefln("%s", exp.eval);
        }
    }
}