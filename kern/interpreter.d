module interpreter;

import leser;
import baum_generator;

import wert;

import glied.glied;
import glied.block_glied;

// @ {} [] # \ || != ~

bool repl_mode = false;
dstring file_name = "";

Wert interpretiere(dstring text)
{
	Glied[] tokens = lese_linie(text);

	Programm_BlockGlied baum = generiere_master_baum(tokens);

	Wert resultat = baum.verwerte(0);

	return resultat;
}
