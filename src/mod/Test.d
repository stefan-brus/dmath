/**
 * Test suite program
 *
 * Runs tests on the .dmath files located in the test folder
 * Follows the configuration in config/test.json
 */

module src.mod.Test;


/**
 * Imports
 */

private import src.core.util.app.Application;

private import src.core.util.File;

private import src.mod.DMath;

private import std.stdio;

private import std.json;


/**
 * Test application class
 */

public class Test : Application
{
    /**
     * Test result enum
     */

    private enum TestResult
    {
        Invalid = 0,
        Failed = 1,
        Succeeded = 2
    }


    /**
     * Test metadata struct
     */

    private struct TestData
    {
        /**
         * The file containing the test expressions
         */

        char[] file;


        /**
         * The name of the test
         */

        char[] name;


        /**
         * The number of tests i the fle
         */

        uint count;


        /**
         * The array of expected solutions for the tests
         */

        double[] solutions;


        /**
         * The array of calculated values for the tests
         */

        double[] values;


        /**
         * The array of test results
         */

         TestResult[] results;


         /**
          * If an error occured during the test, this buffer contains the error message
          */

        char[] err_msg;
    }


    /**
     * DMath instance
     */

    private DMath dmath;


    /**
     * Config JSON object
     */

    private JSONValue config;


    /**
     * Test data array
     */

    private TestData[] tests;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments
     */

    public this ( char[][] str_args )
    {
        super(str_args);

        this.dmath = new DMath([]);
    }


    /**
     * Main application logic method
     *
     * Has its own exception handling to avoid infinite loops
     *
     * Params:
     *      first_run = If this is the first run of the program
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected override bool appMain ( bool first_run )
    {
        try
        {
            writefln("Running DMath test suite\n");
            this.readConfig;
            this.generateTestData;
            this.runTests;
            this.printReport;
        }
        catch ( Exception e )
        {
            writefln("Error: %s", e.msg);
            return false;
        }
        /*auto exps = this.dmath.parseFile(cast(char[])"test/minus.dmath");
        foreach ( exp; exps )
        {
            writefln("%s", exp.eval);
        }*/
        return false;
    }


    /**
     * Application reset method
     */

    protected override void reset ( )
    {
        this.dmath.resetState;
    }


    /**
     * Read the configuration file into the config json object
     */

    private void readConfig ( )
    {
        const CONFIG_FILE = "config/test.json";
        auto json_str = fileAsStr(CONFIG_FILE);
        this.config = parseJSON(json_str);
    }


    /**
     * Generate the test data array from the config JSON object
     */

    private void generateTestData ( )
    in
    {
        assert(this.config["tests"].array.length > 0, "No test data read");
    }
    body
    {
        foreach ( obj; this.config["tests"].array )
        {
            TestData test;
            test.file = cast(char[])obj["file"].str;
            test.name = cast(char[])obj["name"].str;
            test.count = cast(uint)obj["count"].integer;

            foreach ( val; obj["solutions"].array )
            {
                if ( val.type == val.type.FLOAT )
                {
                    test.solutions ~= val.floating;
                }
                else
                {
                    test.solutions ~= val.integer;
                }
            }

            this.tests ~= test;
        }
    }


    /**
     * Run the tests and update the result arrays
     */

    private void runTests ( )
    in
    {
        assert(this.tests.length > 0, "No tests read");
    }
    body
    {
        foreach ( ref test; this.tests )
        {
            auto results = this.dmath.parseFile(test.file);

            if ( results.length != test.solutions.length )
            {
                test.err_msg = cast(char[])"Invalid number of test results";
                continue;
            }

            foreach ( i, exp; results )
            {
                test.values ~= exp.eval;

                if ( exp.eval == test.solutions[i] )
                {
                    test.results ~= TestResult.Succeeded;
                }
                else
                {
                    test.results ~= TestResult.Failed;
                }
            }
        }
    }


    /**
     * Print the result of the tests
     */

    private void printReport ( )
    {
        foreach ( test; this.tests )
        {
            writefln("================================");
            writefln("Test: %s\n", test.name);
            if ( test.err_msg.length > 0 )
            {
                writefln("Error: %s", test.err_msg);
            }
            else
            {
                writefln("Results:\n");

                foreach ( i, result; test.results )
                {
                    if ( result == result.Succeeded )
                    {
                        writefln("Test number %s succeeded", i);
                    }
                    else if ( result == result.Failed )
                    {
                        writefln("Test number %s failed, expected value: %s, received value: %s", i, test.solutions[i], test.values[i]);
                    }
                    else
                    {
                        throw new Exception("Invalid test result");
                    }
                }
            }

            writefln("================================\n");
        }
    }
}