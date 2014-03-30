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

 module src.core.util.dmath.StringEvaluator;


 /**
  * Imports
  */

private import src.core.absyn.Expression;

private import src.core.absyn.ExpressionBuilder;

private import src.core.parser.Parser;

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
     * Params:
     *      str = The expression string
     *
     * Returns:
     *      The evaluated expression
     */

    public Exp eval ( string str )
    {
        auto parse_tree = this.parser.parse(strip(str));

        auto exp = this.exp_builder.build(parse_tree);

        return exp;
    }
}