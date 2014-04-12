/**
 * Constants generator module
 *
 * Reads constants from config/constants.json
 *
 * Usage example:
 * auto consts = new Constants;
 * consts.initConstants;
 */

module dmath.runtime.Constants;


/**
 * Imports
 */

private import dmath.symtab.SymbolTable;

private import dmath.util.dmath.StringEvaluator;

private import dmath.util.tmpl.Singleton;

private import dmath.util.File;

private import dmath.util.JSON;

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
            auto symtab = SymbolTable();
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