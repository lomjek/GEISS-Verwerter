module inerpreter;

import std;

import leser;
import token.token;

// @ {} [] # \ || != ~

uint interpretiere_repl_linie(dchar[] repl_linie)
{
    uint error = 0;

    Token[] tokens = lese_linie(repl_linie, &error);
    return 0;
}
