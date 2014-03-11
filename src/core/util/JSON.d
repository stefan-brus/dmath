/**
 * Utility functions for JSON objects
 */

module src.core.util.JSON;


/**
 * Imports
 */

private import src.core.util.container.HashMap;

private import std.json;


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
}