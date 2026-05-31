module glied.block_glied;

import glied.glied;

import variablen.wert;

import ext.prints;

import std.stdio : writeln, write;

// @ {} [] # \ || != ~

enum BlockTypes
{
	FALLS_SONST,

	SCHLEIFE_PRO_DER,
	SCHLEIFE_SOLANGE,

	FUNKTION
}

abstract class BlockGlied : Glied
{
	public Glied[] aktionen;
}

class Programm_BlockGlied : BlockGlied
{
	override public void schreibe_baum()
	{
		bool first = true;
		write("[BLOCK]{");
		foreach (Glied aktion; aktionen)
		{
			if (!first)
				write(", ");
			aktion.schreibe_baum;
			first = false;
		}
		write("}");
	}

	override public Wert verwerte(uint bereich)
	{
		foreach (Glied aktion; aktionen)
		{
			Wert resultat = aktion.verwerte(0);
			write("Rückgabewert: ");
			schreibe_schön_wert(resultat);
			writeln("");
		}
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return true;
	}
}

class Falls_Sonst_BlockGlied : BlockGlied
{
	public Glied bedingung;
	public Glied[] sonst_aktionen;

	override public void schreibe_baum()
	{
		write("[FALLS ");
		bedingung.schreibe_baum();
		write("]{");
		bool first = true;
		foreach (Glied aktion; aktionen)
		{
			if (!first)
				write(", ");
			aktion.schreibe_baum;
			first = false;
		}
		write("/");
		first = true;
		foreach (Glied aktion; aktionen)
		{
			if (!first)
				write(", ");
			aktion.schreibe_baum;
			first = false;
		}
		write("}");
	}
}
