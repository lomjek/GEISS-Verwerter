module inerpreter;

import std;

import leser;
import baum_generator;

import token.token;
import token.variablen_typ;
import glied.glied;

// @ {} [] # \ || != ~

uint interpretiere_repl_linie(dchar[] repl_linie)
{
    uint error = 0;

    Token[] tokens = lese_linie(repl_linie, &error);
    Glied baum = generiere_baum(tokens);
    auto resultat = baum.verwerte;

    write("Rückgabewert: ");
    if (resultat.typ == VariablenTyp.NATÜRLICHE_ZAHL)
        writeln(*cast(uint*) resultat.wert);
    else if (resultat.typ == VariablenTyp.GANZE_ZAHL)
        writeln(*cast(int*) resultat.wert);
    else if (resultat.typ == VariablenTyp.ZAHL)
        writeln(*cast(double*) resultat.wert);
    else
        writeln(resultat.typ);
    return 0;
}
