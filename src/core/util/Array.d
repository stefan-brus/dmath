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
 * Checks if the given array contains the given element
 *
 * Template Params:
 *      T = The type of elements stored in the array
 *
 * Params:
 *      arr = The array
 *      elm = The element
 *
 * Returns:
 *      True if the array contains the element, false otherwise
 */

public bool contains ( T ) ( T[] arr, T elm )
in
{
    assert(arr.length, "Empty array");
}
body
{
    foreach ( val; arr )
    {
        if ( val == elm )
        {
            return true;
        }
    }

    return false;
}


/**
 * Check if the first array contains any elements of the second array
 *
 * Template Params:
 *      T = The type of element contained in the arrays
 *
 * Params:
 *      arr = The array to check
 *      elms = The elements to look for
 */

public bool contains ( T ) ( T[] arr, T[] elms )
in
{
    assert(arr.length && elms.length, "Empty array");
}
body
{
    foreach ( val; elms )
    {
        if ( contains(arr, val) )
        {
            return true;
        }
    }

    return false;
}


/**
 * Gets the index of the first instance of the given element in the given array
 *
 * The array must contain the element
 *
 * Template Params:
 *      T = The type of elements stored in the array
 *
 * Params:
 *      arr = The array
 *      elm = The element
 *
 * Returns:
 *      The index of the first occurence of elm
 */

public size_t indexOf ( T ) ( T[] arr, T elm )
in
{
    assert(arr.length, "Empty array");
    assert(contains(arr, elm), "Element not in array");
}
body
{
    size_t result;

    foreach ( i, val; arr )
    {
        if ( val == elm )
        {
            result = i;
            break;
        }
    }

    return result;
}


/**
 * Combines all elements in the given list of arrays into one array
 *
 * Template Params:
 *      T = The type of elements stored in the arrays
 *
 * Params:
 *      arrs = The arrays to flatten
 *
 * Returns:
 *      The flattened array
 */

public T[] flatten ( T ) ( T[][] arrs )
in
{
    assert(arrs.length, "Empty array");
}
body
{
    T[] result;

    foreach ( arr; arrs )
    {
        result ~= arr;
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


    /**
     * contains
     */

    assert(contains(arr, 3), err_msg);
    assert(contains(arr, 79), err_msg);
    assert(!contains(arr, 42), err_msg);

    assert(contains(arr, [1, 2, 3]), err_msg);
    assert(contains(arr, [78, 79, 80]), err_msg);
    assert(!contains(arr, [32, 33, 34]), err_msg);


    /**
     * indexOf
     */

    arr ~= 3;
    assert(arr.length == 3, err_msg);
    assert(indexOf(arr, 79) == 1, err_msg);
    assert(indexOf(arr, 3) == 0, err_msg);


    /**
     * flatten
     */

    assert(flatten([[1, 2, 3], [4, 5, 6, 7], [], [8]]) == [1, 2, 3, 4, 5, 6, 7, 8], err_msg);
    assert(flatten(["Flatten ", "Test"]) == "Flatten Test", err_msg);
}