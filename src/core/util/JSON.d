/**
 * Utility functions for JSON objects
 */

module src.core.util.JSON;


/**
 * Imports
 */

private import src.core.util.container.HashMap;

private import std.json;

private import std.string;


/**
 * Convert a JSON object to a hash map
 *
 * Template Params:
 *      T = The value type of the hash map
 *
 * Params:
 *      obj = The JSON object
 *
 * Returns:
 *      The generated HashMap
 */

public HashMap!(char[], T) jsonToMap ( T ) ( JSONValue obj )
in
{
    assert(obj.type == obj.type.OBJECT, "Invalid JSON object");
}
body
{
    auto result = new HashMap!(char[], T);

    foreach ( key, val; obj.object )
    {
        static if ( is(T == char[]) )
        {
            result[cast(char[])key] = cast(char[])val.str;
        }
        else if ( is(T == double) )
        {
            result[cast(char[])key] = cast(double)val.floating;
        }
        else
        {
            assert(false, "Unknown JSON value type");
        }
    }

    return result;
}


/**
 * Convert an array to a JSON array
 *
 * Turns the given array into a JSONValue of the type array
 *
 * Template Params:
 *      T = The type of the array
 *
 * Params:
 *      arr = The array
 */

public JSONValue arrayToJson ( T )  ( T[] arr )
in
{
    assert(arr.length > 0, "Empty array");
}
body
{
    JSONValue result;
    JSONValue[] json_arr;

    foreach ( elm; arr )
    {
        static if ( is(T == char[]) || is(T == string) )
        {
            json_arr ~= parseJSON(format("\"%s\"", elm));
        }
        else
        {
            json_arr ~= parseJSON(format("%s", elm));
        }
    }

    result.array(json_arr);

    return result;
}


/**
 * Convert a JSONValue of type array to an array
 *
 * Template Params:
 *      T = The type of array to return
 *
 * Params:
 *      json = The JSON value
 *
 * TODO: Handle non-string types
 */

public T[] jsonToArray ( T ) ( JSONValue json )
in
{
    assert(json.type == json.type.ARRAY, "Not a JSON array");
}
body
{
    T[] result;

    foreach ( size_t i, val; json )
    {
        static if ( is(T == char[]) || is(T == string) )
        {
            result ~= cast(T)val.str;
        }
    }

    return result;
}


/**
 * Unittests
 */

unittest
{
    /**
     * Error message
     */

    const err_msg = "JSON unittests failed";


    /**
     * jsonToMap
     */

    auto str = "{\"key1\": \"val1\", \"key2\": \"val2\"}";
    auto obj = parseJSON(str);
    auto map = jsonToMap!(char[])(obj);

    assert(cast(char[])"key1" in map, err_msg);
    assert(cast(char[])"key2" in map, err_msg);
    assert(map[cast(char[])"key1"] == "val1", err_msg);
    assert(map[cast(char[])"key2"] == "val2", err_msg);

    auto str2 = "{\"key1\": 1.23, \"key2\": 9.99}";
    auto obj2 = parseJSON(str2);
    auto map2 = jsonToMap!(double)(obj2);

    assert(cast(char[])"key1" in map2, err_msg);
    assert(cast(char[])"key2" in map2, err_msg);
    assert(map2[cast(char[])"key1"] == 1.23, err_msg);
    assert(map2[cast(char[])"key2"] == 9.99, err_msg);


    /**
     * arrayToJson
     */

    auto str_arr = [ "val1", "val2", "val3" ];
    auto json_arr = arrayToJson(str_arr).array;

    assert(json_arr.length == 3, err_msg);
    assert(json_arr[0].str == "val1", err_msg);
    assert(json_arr[1].str == "val2", err_msg);
    assert(json_arr[2].str == "val3", err_msg);

    auto num_arr = [ 1, 2, 3 ];
    auto json_arr2 = arrayToJson(num_arr).array;

    assert(json_arr.length == 3, err_msg);
    assert(json_arr2[0].integer == 1, err_msg);
    assert(json_arr2[1].integer == 2, err_msg);
    assert(json_arr2[2].integer == 3, err_msg);


    /**
     * jsonToArray
     */

    JSONValue json_arr3 = parseJSON("[ \"val1\", \"val2\", \"val3\" ]");
    auto str_arr2 = jsonToArray!(char[])(json_arr3);

    assert(str_arr2.length == 3, err_msg);
    assert(str_arr[0] == cast(char[])"val1", err_msg);
    assert(str_arr[1] == cast(char[])"val2", err_msg);
    assert(str_arr[2] == cast(char[])"val3", err_msg);
}