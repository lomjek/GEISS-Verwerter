module inerpreter;

import std;

import leser;
import baum_generator;

import token.token;

import variablen.wert : WertTyp;

import glied.glied;

// @ {} [] # \ || != ~

uint interpretiere_repl_linie(dstring repl_linie)
{
	uint error = 0;

	Token[] tokens = lese_linie(repl_linie, &error);

	if (error != 0)
	{
		//Print_correct_error
		write("Es ist ein Fehler aufgetretten: ");
		writeln(error);
	}

	Glied baum = generiere_baum(tokens, &error);

	if (error != 0)
	{
		//Print_correct_error
		write("Es ist ein Fehler aufgetretten: ");
		writeln(error);
	}

	auto resultat = baum.verwerte;

	write("Rückgabewert: ");
	if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
		writeln(*cast(uint*) resultat.wert);
	else if (resultat.typ == WertTyp.GANZE_ZAHL)
		writeln(*cast(int*) resultat.wert);
	else if (resultat.typ == WertTyp.ZAHL)
		writeln(*cast(double*) resultat.wert);
	else
		writeln(resultat.typ);
	return 0;
}
