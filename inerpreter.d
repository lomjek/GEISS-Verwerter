module inerpreter;

import std;
import leser;
import token;

// @ {} [] # \ || != ~

uint interpretiere_repl_linie(string repl_linie)
{
    uint error = 0;

    Token[] tokens = lese_linie(repl_linie, &error);
    return 0;
}
