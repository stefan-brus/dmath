/**
 * This module contains the PEG grammar for the DMath language
 */

module src.core.parser.Grammar;


/**
 * Imports
 */

private import pegged.grammar;

mixin(grammar(`
DMath:

    Expr     < Term Assign*
    Assign   < "=" Term

    Term     < Factor (Add / Sub)*
    Add      < "+" Factor
    Sub      < "-" Factor

    Factor   < Comp (Mul / Div)*
    Mul      < "*" Comp
    Div      < "/" Comp

    Comp     < Primary Pow*
    Pow      < "^" Comp

    Primary  < Parens / Neg / Number / Function / Variable
    Parens   < "(" Term ")"
    Neg      < "-" Primary
    Number   < ~([0-9]+) ("." ~([0-9]+))*

    Function < Variable "(" TermList ")"
    TermList < Term ("," Term)*
    Variable <- identifier

`));