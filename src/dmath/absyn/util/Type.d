/**
 * Expression type utility module
 */

module dmath.absyn.util.Type;


/**
 * Imports
 */

private import dmath.absyn.util.ExpTree;

private import dmath.absyn.Expression;

private import dmath.symtab.SymbolTable;

private import dmath.util.tmpl.Singleton;


/**
 * Type utility class
 */

public class TypeUtil : Singleton!(TypeUtil)
{
    /**
     * Infer the type of a given expression
     *
     * If an expression of type complex is found, all expressions are set to type complex
     *
     * Params:
     *      exp = The expression to infer
     *
     * Returns:
     *      The same expression, with all sub expressions containing updated types
     */

    public Exp infer ( Exp exp )
    {
        bool isComplex ( Exp exp )
        {
            if ( cast(Var)exp && exp.str in SymbolTable.instance )
            {
                return SymbolTable.instance[exp.str].exp.type == Type.Complex;
            }
            else if ( cast(FnCall)exp && (cast(FnCall)exp).name in SymbolTable.instance )
            {
                foreach ( arg; (cast(FnCall)exp).args )
                {
                    if ( isComplex(this.infer(arg)) )
                    {
                        return true;
                    }
                }

                return SymbolTable.instance[(cast(FnCall)exp).name].exp.type == Type.Complex;
            }
            else
            {
                return exp.type == Type.Complex;
            }
        }

        Exp setComplex ( Exp exp )
        {
            exp.type = Type.Complex;
            return exp;
        }

        Exp result;

        if ( ExpUtil.instance.exists(exp, &isComplex) )
        {
            result = ExpUtil.instance.replaceIf(exp, ( Exp e ) => !isComplex(e) || cast(Var)e || cast(FnCall)e, &setComplex);
        }
        else
        {
            result = exp;
        }

        return result;
    }
}