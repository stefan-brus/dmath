/**
 * String evaluator module
 *
 * Evaluates a string and returns an expression tree
 *
 * Usage example:
 * auto evaluator = new StringEvaluator;
 * auto str = "2 + 4";
 * evaluator.eval(str); // 6
 */

 module dmath.util.dmath.StringEvaluator;


 /**
  * Imports
  */

private import dmath.absyn.util.Type;

private import dmath.absyn.Expression;

private import dmath.absyn.ExpressionBuilder;

private import dmath.parser.Parser;

private import std.string;


/**
 * String evaluator class
 */

public class StringEvaluator
{
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
     */

    public this ( )
    {
        this.parser = new Parser;
        this.exp_builder = new ExpressionBuilder;
    }


    /**
     * Evaluate a dmath expression string
     *
     * Does type inference
     *
     * Params:
     *      str = The expression string
     *
     * Returns:
     *      The evaluated expression
     */

    debug import std.stdio;

    public Exp eval ( string str )
    {
        auto parse_tree = this.parser.parse(strip(str));

        debug ( Parser ) writefln("DEBUG (Parse tree): %s", parse_tree);

        auto exp = this.exp_builder.build(parse_tree);

        debug ( ExpTree ) writefln("DEBUG (Exp tree): %s", exp.str);

        return TypeUtil().infer(exp);
    }
}