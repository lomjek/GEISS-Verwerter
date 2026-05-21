module glied.block_glied;

import glied.glied;

import variablen.wert;

import std.stdio : writeln;

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

		return Wert(WertTyp.INVALID, null);
	}
}
