/**
 * Utility functions for operating on files
 */

module src.core.util.File;


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
 *      file_name = The name of the file to Read
 *
 * Returns:
 *      The array of strings found in the file
 */

public char[][] readLines ( char[] file_name )
{
    char[][] result;
    auto file = File(cast(string)file_name, "r");

    while ( !file.eof )
    {
        auto line = chomp(file.readln);
        result ~= cast(char[])line;
    }

    return result;
}