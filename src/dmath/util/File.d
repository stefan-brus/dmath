/**
 * Utility functions for operating on files
 */

module dmath.util.File;


/**
 * Imports
 */

private import std.stdio;

private import std.string;


/**
 * Reads the given file and returns it as an array of strings
 * Each string in the array is a line in the file
 *
 * Params:
 *      file_name = The name of the file to read
 *
 * Returns:
 *      The array of strings found in the file
 */

public string[] readLines ( string file_name )
{
    string[] result;
    auto file = File(file_name, "r");

    while ( !file.eof )
    {
        auto line = chomp(file.readln);
        result ~= line;
    }

    return result;
}


/**
 * Reads the given file and returns its contents as a serialized string
 *
 * Manually adds newlines of the format '\n' after each read line
 *
 * Params:
 *      file_name = The name of the file to read
 *
 * Returns:
 *      The contents of the file as a string
 */

 public string fileAsStr ( string file_name )
 {
    string result;
    auto lines = readLines(file_name);

    foreach ( str; lines )
    {
        result ~= str;
        result ~= '\n';
    }

    return result;
 }