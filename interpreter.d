module interpreter;

import std;

import leser;
import baum_generator;

import variablen.wert;

import glied.glied;
import glied.block_glied;

// @ {} [] # \ || != ~

Wert interpretiere(dstring text)
{
	Glied[] tokens = lese_linie(text);

	Programm_BlockGlied baum = generiere_master_baum(tokens);

	Wert resultat = baum.verwerte(0);

	return resultat;
}
