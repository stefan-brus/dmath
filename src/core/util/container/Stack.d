/**
 * Basic, non-optimal implementation of a stack data structure
 *
 * Example usage:
 *
 * auto stack = new Stack!uint;
 *
 * // push two elements onto the stack
 * stack.push(33);
 * stack.push(44);
 *
 * // look at the top element of the stack
 * stack.top; // 44
 *
 * // pop the top element from the stack
 * auto num = stack.pop; // num = 44, stack = [33]
 *
 * // clear stack
 * stack.clear; // stack = []
 */

module src.core.util.container.Stack;


/**
 * Imports
 */

private import src.core.util.Array;


/**
 * Stack implementation
 *
 * Template Params:
 *      T = The stack element type
 */

public class Stack ( T )
{
    /**
     * Internal array of elements
     */

    private T[] elms;


    /**
     * Push an element on top of the stack
     *
     * Params:
     *      elm = The element to push
     */

    public void push ( T elm )
    {
       this.elms ~= elm;
    }


    /**
     * Peek at the element on top of the stack
     * In this implementation, the last element of the internal array
     *
     * Returns:
     *      The element on top of the stack
     */


    public T top ( )
    {
        if ( this.elms.length > 0 )
        {
            return this.elms[this.elms.length - 1];
        }
        return null;
    }


    /**
     * Pop the element on top of the stack
     * In this implementation, the last element of the internal array
     *
     * Returns:
     *      The element on top of the stack
     */

    public T pop ( )
    {
        T result = this.top;
        if ( this.elms.length > 0 )
        {
            this.elms = remove(this.elms, this.elms.length - 1);
        }
        return result;
    }


    /**
     * Get the size of the stack
     *
     * Returns:
     *      The number of elements in the stack
     */

    public size_t size ( )
    {
        return this.elms.length;
    }


    /**
     * Clear the stack
     */

    public void clear ( )
    {
        this.elms.length = 0;
    }
}