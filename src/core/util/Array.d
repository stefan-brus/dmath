/**
 * Utility functions for operating on arrays
 */

module src.core.util.Array;


/**
 * Remove an element at the given index from the given array
 *
 * Template Params:
 *      T = The type of the elements stored in the array
 *
 * Params:
 *      arr = The array
 *      idx = The index
 *
 * Returns:
 *      The array with the element removed
 */

public T[] remove ( T ) ( T[] arr, size_t idx )
in
{
    assert(arr.length, "Empty array");
    assert(idx < arr.length, "Index out of bounds");
}
body
{
    T[] result;
    auto size = arr.length;
    if ( idx == 0 )
    {
        for ( int i = 1; i < size; i++ )
        {
            result ~= arr[i];
        }
    }
    else if ( idx == size - 1 )
    {
        for ( int i = 0; i < size - 1; i++ )
        {
            result ~= arr[i];
        }
    }
    else
    {
        for ( int i = 0; i < idx; i++ )
        {
            result ~= arr[i];
        }

        for ( int i = idx + 1; i < size; i++ )
        {
            result ~= arr[i];
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

    const err_msg = "Array unittests failed";


    /**
     * remove
     */

    int[] arr = [1, 3, 5, 79, 616];

    arr = remove(arr, 2);
    assert(arr.length == 4, err_msg);
    assert(arr[2] == 79, err_msg);

    arr = remove(arr, 0);
    assert(arr.length == 3, err_msg);
    assert(arr[0] == 3, err_msg);

    arr = remove(arr, 2);
    assert(arr.length == 2, err_msg);
    assert(arr[1] == 79, err_msg);
}