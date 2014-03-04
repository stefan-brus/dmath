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