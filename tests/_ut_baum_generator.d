module tests.baum_generator;

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
		new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(Gzahl(Nzahl([0x20, 0x03])), Bruch()))),
		new OperationGlied(OperatorenTyp.PLUS),
		new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(Gzahl(Nzahl([0x21, 0x03])), Bruch()))),
	];
	assert(baue_glied(glied_liste_plus, 1)[0].ist_vollständig);
	writeln("läuft");

	write("Testiere parse_glied_Sonst_Glied...");
	Sonst_BlockGlied sbg = new Sonst_BlockGlied();
	Wert_Glied nullg = new Wert_Glied(Wert());
	Glied[] glied_liste_sonst = [
		sbg,
		nullg
	];
	glied_liste_sonst = baue_glied_Sonst_Glied(sbg, glied_liste_sonst, 0);
	assert(glied_liste_sonst.length == 1);
	assert((cast(Sonst_BlockGlied) glied_liste_sonst[0]).aktionen[0] == nullg);
	writeln("läuft");

	write("Testiere finde_MPO...");
	{
		Glied[] glieder_liste = [
			new Wert_Glied(Wert()),
			new OperationGlied(OperatorenTyp.PLUS),
			new Wert_Glied(Wert()),
			new OperationGlied(OperatorenTyp.MAL),
			new Wert_Glied(Wert())
		];

		MPO mpo = finde_MPO(glieder_liste);

		assert(mpo.index == 3);
	}

	writeln("läuft");

	writeln("========================================");
	writeln("Der Parser funktioniert!");
	writeln("========================================");
	writeln;
}
