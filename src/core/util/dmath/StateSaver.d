/**
 * Utility module for saving and loading the state of the DMath program
 *
 * Saves all user defined variables and functions in the symbol table
 *
 * Usage example:
 * auto saver = new StateSaver("state.json"); // Read and write file "state.json"
 * saver.save; // Save the state
 * saver.load; // Load the state
 */

module src.core.util.dmath.StateSaver;


/**
 * Imports
 */

private import src.core.absyn.util.Function;

private import src.core.symtab.Symbols;

private import src.core.symtab.SymbolTable;

private import src.core.util.dmath.StringEvaluator;

private import src.core.util.Array;

private import src.core.util.File;

private import src.core.util.JSON;

private import std.file;

private import std.json;

private import std.string;


/**
 * Save exception class
 */

public class SaveException : Exception
{
    /**
     * Constructor
     *
     * Params:
     *      msg = The error message
     */

    public this ( char[] msg )
    {
        super(cast(string)msg);
    }
}


/**
 * State saver class
 */

public class StateSaver
{
    /**
     * The string evaluator
     */

    private StringEvaluator evaluator;


    /**
     * The file to read and write
     */

    private const char[] file;


    /**
     * Constructor
     *
     * Params:
     *      evaluator = The string evaluator
     *      file = The file to read and write
     */

    public this ( StringEvaluator evaluator, char[] file )
    {
        this.evaluator = evaluator;
        this.file = file;
    }


    /**
     * Save the user defined variables and functions to the file
     *
     * Serializes the contents of the symbol table into a JSON string
     */

    public void save ( )
    {
        JSONValue[string] json_obj;

        foreach ( name, sym; SymbolTable.instance )
        {
            if ( cast(Variable)sym )
            {
                JSONValue val;
                val.str(cast(string)sym.exp.str);
                json_obj[cast(string)name] = val;
            }
            else if ( cast(Function)sym )
            {
                JSONValue val;
                JSONValue[string] func_obj;
                JSONValue exp_obj;
                JSONValue args_obj;

                exp_obj.str(cast(string)sym.exp.str);
                args_obj.array(arrayToJson((cast(Function)sym).args).array);
                func_obj["exp"] = exp_obj;
                func_obj["args"] = args_obj;
                val.object(func_obj);

                json_obj[cast(string)name] = val;
            }
        }

        JSONValue json;
        json.object(json_obj);

        std.file.write(this.file, json.toPrettyString);
    }


    /**
     * Reads the user defined variables and functions from the file, if it exists
     *
     * Catches and prints symbol table errors, but continues writing the state anyway
     *
     * Throws:
     *      SaveException, if any JSON errors occur
     */

    public void load ( )
    {
        if ( !exists(this.file) )
        {
            return;
        }

        try
        {
            auto json_str = fileAsStr(this.file);
            auto json_obj = parseJSON(json_str);

            if ( json_obj.type != json_obj.type.OBJECT )
            {
                char[] msg = cast(char[])"Invalid JSON object type";
                throw new SaveException(msg);
            }

            foreach ( string key, val; json_obj )
            {
                if ( val.type == val.type.STRING )
                {
                    auto exp = this.evaluator.eval(cast(char[])val.str);
                    SymbolTable.instance[cast(char[])key] = exp;
                }
                else if ( val.type == val.type.OBJECT )
                {
                    auto exp = this.evaluator.eval(cast(char[])val.object["exp"].str);
                    auto args = jsonToArray!(char[])(val.object["args"]);
                    FnUtil.instance.putFunction(cast(char[])key, exp, args);
                }
            }
        }
        catch ( Exception e )
        {
            char[] msg = cast(char[])"Error loading: " ~ e.msg;
            throw new SaveException(msg);
        }
    }
}