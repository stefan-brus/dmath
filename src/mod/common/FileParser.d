/**
 * File parser module
 *
 * Parses a '.dmath' file containing DMath expressions
 * Returns an array of parsed expressions
 *
 * Usage example:
 * auto file_parser = new FileParser;
 * Exp[] expressions = file_parser.parse(cast(char[])"math.dmath");
 */

module src.mod.common.FileParser;


/**
 * Imports
 */

private import src.core.absyn.Expression;

private import src.core.util.File;

private import src.mod.common.StringEvaluator;


/**
 * File parser class
 */

public class FileParser
{
    /**
     * Buffer for generated expressions
     */

    private Exp[] exp_buf;


    /**
     * String to expression evaluator
     */

    private StringEvaluator evaluator;


    /**
     * Constructor
     */

    public this ( )
    {
        this.evaluator = new StringEvaluator;
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
        this.exp_buf.length = 0;
        auto lines = readLines(file);

        foreach ( str; lines )
        {
            this.exp_buf ~= this.evaluator.eval(str);
        }

        return this.exp_buf;
    }


    /**
     * Reset the state of the file parser
     */

    public void reset ( )
    {
        this.exp_buf.length = 0;
        this.evaluator.reset;
    }
}