module glied.block_glied;

import glied.glied;

import variablen.wert;

import std.stdio : writeln, write;

// @ {} [] # \ || != ~

enum BlockTypes
{
	GLOBAL,

	FALLS_SONST,

	SCHLEIFE_PRO_DER,
	SCHLEIFE_SOLANGE,

	FUNKTION
}

class BlockGlied : Glied
{
	public Glied[] aktionen;
	BlockTypes typ;

	override public void schreibe_baum()
	{
		writeln();
	}

	override public Wert verwerte(uint bereich)
	{
		foreach (Glied aktion; aktionen)
		{
			auto resultat = aktion.verwerte(bereich);
			write("Rückgabewert: ");
			if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
				writeln(*cast(uint*) resultat.wert);
			else if (resultat.typ == WertTyp.GANZE_ZAHL)
				writeln(*cast(int*) resultat.wert);
			else if (resultat.typ == WertTyp.ZAHL)
				writeln(*cast(double*) resultat.wert);
			else
				writeln(resultat.typ);
		}
		return Wert(WertTyp.INVALID, null);
	}
}
