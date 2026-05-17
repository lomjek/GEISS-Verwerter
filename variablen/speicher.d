module variablen.speicher;

import variablen.bereich;
import variablen.variable;

import ext.string;

Bereich*[] bereiche;

static this()
{
	bereiche ~= new Bereich("global".dchar_from_string, 0, [
			//Hier müssten so Sachen sein wie name der Datei, eine exit Funktion, usw, usw...
		]);
}
