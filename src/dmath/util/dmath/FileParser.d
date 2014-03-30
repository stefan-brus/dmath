/**
 * File parser module
 *
 * Parses a '.dmath' file containing DMath expressions
 * Returns an array of parsed expressions
 *
 * Usage example:
 * auto file_parser = new FileParser;
 * Exp[] expressions = file_parser.parse("math.dmath");
 */

module dmath.util.dmath.FileParser;


/**
 * Imports
 */

private import dmath.absyn.Expression;

private import dmath.util.dmath.StringEvaluator;

private import dmath.util.File;

private import dmath.util.String;

private import std.string;


/**
 * File parser class
 */

public class FileParser
{
    /**
     * Parse error handler delegate alias
     */

    private alias void delegate ( size_t idx, string msg ) ErrorDg;


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
     *
     * Treats each line as a dmath expression, evaluates it and returns the resulting expressions
     *
     * Skips empty lines and lines starting with comments
     *
     * Params:
     *      file = The name of the file to parse
     *      err_dg = Optional error handler delegate
     *
     * Returns:
     *      The generated list of expressions
     */

    public Exp[] parseFile ( string file, ErrorDg dg = null )
    {
        this.exp_buf.length = 0;

        auto lines = readLines(file);

        uint exp_no = 0;

        foreach ( str; lines )
        {
            if ( strip(str).length == 0 )
            {
                continue;
            }

            if ( isComment(str) )
            {
                continue;
            }

            try
            {
                this.exp_buf ~= this.evaluator.eval(str);
            }
            catch ( Exception e )
            {
                if ( dg !is null )
                {
                    dg(exp_no, e.msg);
                }
                else
                {
                    throw e;
                }
            }

            exp_no++;
        }

        return this.exp_buf;
    }


    /**
     * Reset the state of the file parser
     */

    public void reset ( )
    {
        this.exp_buf.length = 0;
    }
}