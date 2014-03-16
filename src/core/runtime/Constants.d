/**
 * Constants generator module
 *
 * Reads constants from config/constants.json
 *
 * Usage example:
 * auto consts = new Constants;
 * consts.initConstants;
 */

module src.core.runtime.Constants;


/**
 * Imports
 */

private import src.core.symtab.SymbolTable;

private import src.core.util.dmath.StringEvaluator;

private import src.core.util.tmpl.Singleton;

private import src.core.util.File;

private import src.core.util.JSON;

private import std.json;

private import std.stdio;


/**
 * Constants class
 *
 * Implemented as a singleton
 */

public class Constants : Singleton!(Constants)
{
    /**
     * Initialize constants
     *
     * Reads and evaluates constant expressions from config/constants.json
     * Puts their names and values in the symbol talbe as constants
     * Performs its owne error handling to avoid infinite loops
     */

    public void initConstants ( )
    {
        try
        {
            auto symtab = SymbolTable.instance;
            auto json_str = fileAsStr("config/constants.json");
            auto json = parseJSON(json_str);
            auto map = jsonToMap!(double)(json);

            foreach ( name, value; map )
            {
                symtab.putConstant(name, value);
            }
        }
        catch ( Exception e )
        {
            writefln("Error initializing constants: %s", e.msg);
        }
    }
}