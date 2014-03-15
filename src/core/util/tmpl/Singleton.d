/**
 * Singleton base class template
 */

module src.core.util.tmpl.Singleton;


/**
 * Singleton
 *
 * Template Params:
 *      T = The type of the singleton instance
 */

public class Singleton ( T )
{
    /**
     * Singleton instance
     */

    private static T _instance;


    /**
     * Constructor
     *
     * Protected, use static instance() method to get instance
     */

    protected this ( )
    {
        this.init;
    }


    /**
     * Singleton instance method
     *
     * Returns:
     *      The singleton instance
     */

    public static T instance ( )
    {
        if ( _instance is null )
        {
            _instance = new T;
        }

        return _instance;
    }


    /**
     * Class initializer method, override this if necessary
     */

    protected void init ( )
    {

    }
}