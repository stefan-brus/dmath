/**
 * Basic, non-optimal implementation of a queue data structure
 *
 * Example usage:
 *
 * auto queue = new Queue!uint;
 *
 * // enqueue two elements
 * queue.enqueue(33);
 * queue.enqueue(44);
 *
 * // look at the front element of the queue
 * queue.front; // 33
 *
 * // remove the element at the front of the queue
 * auto num = queue.dequeue; // num = 33, queue = [44]
 *
 * // clear the queue
 * queue.clear; // queue = []
 */

module src.core.util.container.Queue;


/**
 * Imports
 */

private import std.algorithm;


/**
 * Queue implementation
 *
 * Template Params:
 *      T = The queue element type
 */

public class Queue ( T )
{
    /**
     * Internal array of elements
     */

    private T[] elms;


    /**
     * Add an element to the queue
     *
     * Params:
     *      elm = The element to enqueue
     */

    public void enqueue ( T elm )
    {
        this.elms ~= elm;
    }


    /**
     * Look at the element at the front of the queue
     * In this implementation, the first element of the internal array
     *
     * Returns:
     *      The element at the front of the queue
     */

    public T front ( )
    {
        if ( this.elms.length > 0 )
        {
            return this.elms[0];
        }
        return null;
    }


    /**
     * Remove the element at the front of the queue
     * In this implementation, the first element of the internal array
     *
     * Returns:
     *      The element at the front of the queue
     */

    public T dequeue ( )
    {
        T result = this.front;
        if ( this.elms.length > 0 )
        {
            this.elms = remove(this.elms, 0);
        }
        return result;
    }


    /**
     * Get the size of the queue
     *
     * Returns:
     *      The number of elements in the queue
     */

    public size_t size ( )
    {
        return this.elms.length;
    }


    /**
     * Clear the queue
     */

    public void clear ( )
    {
        this.elms.length = 0;
    }
}