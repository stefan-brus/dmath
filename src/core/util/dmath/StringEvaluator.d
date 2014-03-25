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

private import src.core.lexer.InputTokenizer;

private import src.core.parser.Parser;

private import std.string;


/**
 * String evaluator class
 */

public class StringEvaluator
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
     */

    public this ( )
    {
        this.tokenizer = new InputTokenizer;
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
        bool is_assignment;

        auto tokens = tokenizer.parse(strip(str));

        auto post_queue = this.parser.parse(tokens, is_assignment);

        auto exp = this.exp_builder.buildExpression(post_queue, is_assignment);

        return exp;
    }


    /**
     * Reset the state of the string evaluator
     */

    public void reset ( )
    {
        this.tokenizer.reset;
        this.parser.reset;
        this.exp_builder.reset;
    }
}