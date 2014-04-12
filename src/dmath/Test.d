/**
 * Test suite program
 *
 * Runs tests on the .dmath files located in the test folder
 * Follows the configuration in config/test.json
 * Uses std.math.approxEqual to compare numbers, because of floating point fuckery
 */

module dmath.Test;


/**
 * Imports
 */

private import dmath.absyn.Expression;

private import dmath.runtime.Constants;

private import dmath.util.app.Application;

private import dmath.util.container.HashMap;

private import dmath.util.dmath.FileParser;

private import dmath.util.File;

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

        ValType[] solutions;


        /**
         * The array of calculated values for the tests
         */

        ValType[] values;


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
                if ( val.type == val.type.ARRAY )
                {
                    test.solutions ~= this.makeComplex(val.array);
                }
                else
                {
                    test.solutions ~= this.makeNum(val);
                }
            }

            test.parse_errs.length = test.solutions.length;

            this.tests ~= test;
        }
    }


    /**
     * Create a complex value from the given JSON array
     *
     * Params:
     *      arr = The JSON array
     *
     * Returns:
     *      The complex value
     */

    private ValType makeComplex ( JSONValue[] arr )
    in
    {
        assert(arr.length == 2, "Invalid complex number format");
    }
    body
    {
        double val_real = this.makeNum(arr[0]).val;
        double val_imag = this.makeNum(arr[1]).val;

        return cast(ValType)ComplexVal(val_real, val_imag);
    }


    /**
     * Create a number from the given JSON value
     *
     * Params:
     *      val = The JSON value
     *
     * Returns:
     *      The number value
     */

    private ValType makeNum ( JSONValue val )
    {
        if ( val.type == val.type.FLOAT )
        {
            return ValType(cast(double)val.floating);
        }
        else
        {
            return ValType(cast(double)val.integer);
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

                if ( exp.type == exp.type.Real &&
                     approxEqual(exp.eval.val, test.solutions[i].val) )
                {
                    test.results ~= TestResult.Succeeded;
                }
                else if ( exp.type == exp.type.Complex &&
                          this.compareComplex(exp.eval.complex, test.solutions[i].complex) )
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
     * Compare two complex numbers
     *
     * Params:
     *      c1 = The first complex number
     *      c2 = The second complex number
     *
     * Returns:
     *      True if they are approximately equal, false otherwise
     */

    private bool compareComplex ( ComplexVal c1, ComplexVal c2 )
    {
        return approxEqual(c1.real_val, c2.real_val) &&
               approxEqual(c1.imag_val, c2.imag_val);
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


/**
 * Main function
 */

void main ( string[] args )
{
    auto test = new Test(args);
    test.run;
}