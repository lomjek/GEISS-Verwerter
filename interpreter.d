module interpreter;

import std;

import leser;
import baum_generator;

import token.token;

import variablen.wert : WertTyp;

import glied.glied;

// @ {} [] # \ || != ~

uint interpretiere(dstring text)
{
	uint error = 0;

	Token[] tokens = lese_linie(text, &error);

	if (error != 0)
	{
		//Print_correct_error
		write("Es ist ein Fehler aufgetretten: ");
		writeln(error);
	}

	Glied baum = generiere_master_baum(tokens, &error);

	if (error != 0)
	{
		//Print_correct_error
		write("Es ist ein Fehler aufgetretten: ");
		writeln(error);
	}

	auto resultat = baum.verwerte(0);

	return 0;
}
