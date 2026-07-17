module ut_baum_generator;

import baum_generator;

import glied;
import zahl;
import operatoren;
import variablen.wert;

import std.stdio : write, writeln;

// @ {} [] # \ || != ~

unittest
{
	writeln("========================================");
	writeln("Testiere den Parser");
	writeln("========================================");

	writeln("Testiere parse_glied:");

	write("Testiere parse_glied_OperationGlied...");
	Glied[] glied_liste_plus = [
		new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(false, Bruch(), [0x20, 0x03]))),
		new OperationGlied(OperatorenTyp.PLUS),
		new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(false, Bruch(), [0x21, 0x03]))),
	];
	assert(parse_glied(glied_liste_plus, 1)[0].ist_vollständig);
	writeln("läuft");

	writeln("========================================");
	writeln("Der Parser funktioniert!");
	writeln("========================================");
	writeln;
}
