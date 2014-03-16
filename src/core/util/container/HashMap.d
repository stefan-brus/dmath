/**
 * Basic, non-optimal implementation of a hash map data structure
 *
 * Uses linked lists for internal bucket storage.
 * The hash map is initialized with INITIAL_SIZE (default: 8) elements.
 * Once LOAD_FACTOR (default: 0.75) has been reached, the size doubles.
 *
 * The hash function is based on the FNV-1a algorithm:
 * http://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
 *
 * Example usage:
 *
 * auto map = new HashMap!(char[], uint);
 *
 * // Put two elements in the map
 * map["one"] = 1;
 * map["two"] = 2;
 *
 * // Check if map contains an element
 * "one" in map; // true
 *
 * // Get an element from the map
 * map["one"]; // 1
 *
 * // Remove an element from the map
 * map.remove("one"); // map = ["two": 2]
 *
 * // Empty the map
 * map.clear; // map = []
 */

module src.core.util.container.HashMap;


/**
 * Hash map class
 *
 * Template Params:
 *      K = The key type
 *      V = The value type
 */

public class HashMap ( K, V )
{
    /**
     * Initial size of the map
     */

    private static const INITIAL_SIZE = 8;


    /**
     * How filled the map can be before size doubles
     */

    private static const LOAD_FACTOR = 0.75;


    /**
     * Struct representing an entry in the map
     *
     * Uses a linked list for internal bucket storage
     *
     * Template Params:
     *      K = The key type
     *      V = The value type
     */

    private class Entry ( K, V )
    {
        /**
         * The key
         */

        public K key;


         /**
          * The value
          */

        public V val;


        /**
         * The next entry in the bucket
         */

        public Entry!(K, V) next;


        /**
         * Constructor
         *
         * Params:
         *      key = The key
         *      val = The value
         */

        public this ( K key, V val )
        {
            this.key = key;
            this.val = val;
        }
    }

    /**
     * The list of entries
     */

    private Entry!(K, V)[] entries;


    /**
     * Constructor
     */

    public this ( )
    {
        this.entries = new Entry!(K, V)[this.INITIAL_SIZE];
    }


    /**
     * Index assignment operators
     * Put en entry into the map
     * Performs a rehash if necessary
     *
     * Params:
     *      val = The value
     *      key = The key
     */

    public void opIndexAssign ( V val, K key )
    in
    {
        assert(key, "Key must not be null");
    }
    body
    {
        auto idx = this.indexOf(key, this.entries.length);
        auto entry = this.entries[idx];

        if ( entry )
        {
            while ( entry )
            {
                if ( key == entry.key )
                {
					// entry found, replace old value with new value
                    entry.val = val;
                }
                else if ( !entry.next )
                {
                    entry.next = new Entry!(K, V)(key, val);
                }

                entry = entry.next;
            }
        }
        else
        {
            // no entry found, put the new entry at the index
            this.entries[idx] = new Entry!(K, V)(key, val);
        }

        if ( this.size > this.entries.length * this.LOAD_FACTOR )
        {
            this.rehash;
        }
    }


    /**
     * Index operator
     * Get the value for the given key
     *
     * Params:
     *      key = The key
     *
     * Returns:
     *      The value for the key
     */

    public V opIndex ( K key )
    in
    {
        assert(key in this, "Key must exist in map");
    }
    body
    {
        auto idx = this.indexOf(key, this.entries.length);
        auto entry = this.entries[idx];

        while ( entry && entry.key != key )
        {
            entry = entry.next;
        }

        return entry.val;
    }


    /**
     * In operator
     * Enables usage of "key in map" syntax
     *
     * Params:
     *      key = The key
     *
     * Returns:
     *      True if the key is in the map, false otherwise
     */

    public bool opIn_r ( K key )
    in
    {
        assert(key, "Key must not be null");
    }
    body
    {
        auto idx = this.indexOf(key, this.entries.length);
        auto entry = this.entries[idx];

        while ( entry )
        {
            if ( entry.key == key )
            {
                return true;
            }

            entry = entry.next;
        }

        return false;
    }


    /**
     * Foreach operator
     * Enables foreach iteration over key-value pairs
     * Goes through the internal entry array and skips null entries
     *
     * Params:
     *      dg = The opApply delegate
     *
     * Returns:
     *      Who knows
     */

    public int opApply ( int delegate ( ref K key, ref V val ) dg )
    {
        int result = 0;

        foreach ( entry; this.entries )
        {
            if ( entry is null )
            {
                continue;
            }

            result = dg(entry.key, entry.val);

            while ( entry.next !is null )
            {
                entry = entry.next;
                result = dg(entry.key, entry.val);
            }

            if ( result > 0 )
            {
                break;
            }
        }

        return result;
    }


    /**
     * Remove an entry from the map
     *
     * Params:
     *      key = The key of the entry to remove
     */

    public void remove ( K key )
    in
    {
        assert(key in this, "Key must exist in map");
    }
    body
    {
        auto idx = this.indexOf(key, this.entries.length);
        auto entry = this.entries[idx];

        if ( entry.key == key )
        {
            if ( entry.next )
            {
                auto next = entry.next;
                delete this.entries[idx];
                this.entries[idx] = next;
            }
            else
            {
                delete this.entries[idx];
                this.entries[idx] = null;
            }
        }
        else
        {
            auto prev = entry;
            while ( entry.next.key != key )
            {
                prev = entry;
                entry = entry.next;
            }

            prev.next = entry.next;
            delete entry;
        }
    }


    /**
     * Get the size of the map
     *
     * Returns:
     *      The number of entries in the buckets
     */

    public size_t size ( )
    {
        size_t result;

        foreach ( entry; this.entries )
        {
            if ( entry )
            {
                result++;

                while ( entry.next )
                {
                    result++;
                    entry = entry.next;
                }
            }
        }

        return result;
    }


    /**
     * Clear the map
     */

    public void clear ( )
    {
        delete this.entries;
        this.entries.length = this.INITIAL_SIZE;
    }


    /**
     * Rehash the map
     *
     * Doubles the size of the internal buckets and assigns new indices to all entries.
     */

    private void rehash ( )
    {
        auto new_entries = new Entry!(K, V)[this.entries.length * 2];

        foreach ( entry; this.entries )
        {
            while ( entry )
            {
                // search through buckets and assign new indices where appropriate
                auto idx = indexOf(entry.key, new_entries.length);
                auto next_entry = entry.next;

                entry.next = new_entries[idx];
                new_entries[idx] = entry;
                entry = next_entry;
            }
        }

        this.entries = new_entries;
    }


    /**
     * Gets the index in the entry list for the given key
     *
     * Params:
     *      key = The key
     *      len = The length of the entry bucket array
     *
     * Returns:
     *      The index for the key
     */

    private size_t indexOf ( K key, size_t len )
    {
        return hash(key) % len;
    }


    /**
     * FNV-1a hash function
     *
     * Params:
     *      key = The key to hash
     *
     * Returns:
     *      The hash for the given key
     */

    private ulong hash ( K key )
    {
		const FNV_OFFSET_BASIS = 0xCBF2_9CE4_8422_2325;
		const FNV_PRIME = 0x0000_0100_0000_01B3; // prime

		ulong digest = FNV_OFFSET_BASIS;
        ubyte[] data = cast(ubyte[])key;

		foreach (d; data) {
			digest ^= d;
            digest *= FNV_PRIME;
		}

		return digest;
    }
}


/**
 * Unittests
 */

unittest
{
    /**
     * Error message
     */

    const err_msg = "HashMap unittests failed";


    /**
     * HashMap tests
     */

    auto map = new HashMap!(string, uint);

    assert(map.size == 0, err_msg);

    map["one"] = 1;
    assert(map.size == 1, err_msg);
    assert("one" in map, err_msg);
    assert(map["one"] == 1, err_msg);

    map["two"] = 2;
    map["three"] = 3;

    assert(map.size == 3, err_msg);
    assert("two" in map, err_msg);
    assert("three" in map, err_msg);

    foreach ( k, v; map )
    {
        assert(v > 0 && v < 4, err_msg);
        if ( v == 1 )
        {
            assert(k == "one", err_msg);
        }
        else if ( v == 2 )
        {
            assert(k == "two", err_msg);
        }
        else if ( v == 3 )
        {
            assert(k == "three", err_msg);
        }
    }

    map["four"] = 4;
    map["five"] = 5;
    map["six"] = 6;
    map["seven"] = 7;
    map["eight"] = 8;
    map["nine"] = 9;
    map["ten"] = 10;
    map["eleven"] = 11;
    map["twelve"] = 12;
    map["thirteen"] = 13;
    map["fourteen"] = 14;
    map["fifteen"] = 15;
    map["sixteen"] = 16;
    map["seventeen"] = 17;
    assert(map.size == 17, err_msg);
    assert(map["one"] == 1, err_msg);
    assert(map["two"] == 2, err_msg);
    assert(map["three"] == 3, err_msg);
    assert(map["four"] == 4, err_msg);
    assert(map["five"] == 5, err_msg);
    assert(map["six"] == 6, err_msg);
    assert(map["seven"] == 7, err_msg);
    assert(map["eight"] == 8, err_msg);
    assert(map["nine"] == 9, err_msg);
    assert(map["ten"] == 10, err_msg);
    assert(map["eleven"] == 11, err_msg);
    assert(map["twelve"] == 12, err_msg);
    assert(map["thirteen"] == 13, err_msg);
    assert(map["fourteen"] == 14, err_msg);
    assert(map["fifteen"] == 15, err_msg);
    assert(map["sixteen"] == 16, err_msg);
    assert(map["seventeen"] == 17, err_msg);

    map.remove("one");
    assert(map.size == 16, err_msg);

    map.clear;
    assert(map.size == 0, err_msg);
}