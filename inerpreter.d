module inerpreter;

import std;

import leser;
import baum_generator;

import token.token;
import glied.glied;

// @ {} [] # \ || != ~

uint interpretiere_repl_linie(dchar[] repl_linie)
{
    uint error = 0;

    Token[] tokens = lese_linie(repl_linie, &error);
    Glied baum = generiere_baum(tokens);
    return 0;
}
