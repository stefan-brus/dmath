/**
 * Test suite program
 *
 * Runs tests on the .dmath files located in the test folder
 * Follows the configuration in config/test.json
 * Uses std.math.approxEqual to compare numbers, because of floating point fuckery
 */

module src.mod.Test;


/**
 * Imports
 */

private import src.core.runtime.Constants;

private import src.core.util.app.Application;

private import src.core.util.container.HashMap;

private import src.core.util.dmath.FileParser;

private import src.core.util.File;

private import std.math;

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

        string file;


        /**
         * The name of the test
         */

        string name;


        /**
         * The description of the test
         */

        string description;


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
          * If a fatal error occured during the test, this buffer contains the error message
          */

        string fatal;


        /**
         * Error messages caught during the parsing of the test file are stored here
         */

        string[] parse_errs;
    }


    /**
     * File parser
     */

    private FileParser file_parser;


    /**
     * Config JSON object
     */

    private JSONValue config;


    /**
     * Test data array
     */

    private TestData[] tests;


    /**
     * Test result summary data, tests run and tests failed
     */

    private uint tests_run;

    private uint tests_failed;


    /**
     * Constructor
     *
     * Params:
     *      str_args = The command line arguments
     */

    public this ( string[] str_args )
    {
        super(str_args);

        this.file_parser = new FileParser;
    }


    /**
     * Process the command line arguments
     *
     * Returns:
     *      True if the program should keep running, false otherwise
     */

    protected override bool processArgs ( )
    {
        return true;
    }


    /**
     * Main application logic method
     *
     * Initializes constants
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
        Constants.instance.initConstants;

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

        return false;
    }


    /**
     * Application reset method
     */

    protected override void reset ( )
    {
        this.file_parser.reset;
        this.tests.length = 0;
        this.tests_run = 0;
        this.tests_failed = 0;
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
            test.file = obj["file"].str;
            test.name = obj["name"].str;
            test.description = obj["description"].str;
            test.count = cast(uint)obj["count"].integer;

            foreach ( val; obj["solutions"].array )
            {
                if ( val.type == val.type.FLOAT )
                {
                    test.solutions ~= cast(double)val.floating;
                }
                else
                {
                    test.solutions ~= val.integer;
                }
            }

            test.parse_errs.length = test.solutions.length;

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
            void errorHandler ( size_t test_idx, string msg )
            {
                if ( test_idx < test.parse_errs.length )
                {
                    test.parse_errs[test_idx] = msg;
                }
            }

            auto results = this.file_parser.parseFile(test.file, &errorHandler);

            if ( results.length != test.solutions.length )
            {
                test.fatal = "Invalid number of test results";
                continue;
            }

            foreach ( i, exp; results )
            {
                this.tests_run++;

                test.values ~= exp.eval;

                if ( approxEqual(exp.eval, test.solutions[i]) )
                {
                    test.results ~= TestResult.Succeeded;
                }
                else
                {
                    this.tests_failed++;

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
        uint fatal_err_count;
        uint parse_err_count;

        auto fail_map = new HashMap!(string, uint[]);

        foreach ( test; this.tests )
        {
            writefln("================================");
            writefln("Test: %s\n\n%s\n", test.name, test.description);

            if ( test.fatal.length > 0 )
            {
                fatal_err_count++;

                writefln("Fatal error: %s\n", test.fatal);

                foreach ( i, err; test.parse_errs )
                {
                    if ( err.length > 0 )
                    {
                        parse_err_count++;

                        writefln("Test number %s, parse error: %s", i + 1, err);
                    }
                }
            }
            else
            {
                writefln("Results:\n");

                foreach ( i, result; test.results )
                {
                    if ( result == result.Succeeded )
                    {
                        writefln("Test number %s succeeded", i + 1);
                    }
                    else if ( result == result.Failed )
                    {
                        if ( !(test.name in fail_map) )
                        {
                            fail_map[test.name] = [];
                        }

                        fail_map[test.name] = fail_map[test.name] ~ (i + 1);

                        writefln("Test number %s failed, expected value: %s, received value: %s", i + 1, test.solutions[i], test.values[i]);
                    }
                    else
                    {
                        throw new Exception("Invalid test result");
                    }
                }
            }

            writefln("================================\n");
        }

        writefln("Summary:\n");
        writefln("Tests run: %s", this.tests_run);
        writefln("Out of which failed: %s", this.tests_failed);
        writefln("Fatal errors: %s", fatal_err_count);
        writefln("Parse errors: %s", parse_err_count);
        writefln("");

        if ( fail_map.size > 0 )
        {
            writefln("Failed tests:");

            foreach ( name, fails; fail_map )
            {
                foreach ( fail; fails )
                {
                    writefln("Test '%s' number %s failed", name, fail);
                }
            }
        }
    }
}