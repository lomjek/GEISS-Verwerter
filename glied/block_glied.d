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

class BlockGlied : Glied
{
	public Glied[] aktionen;

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
			Wert resultat = aktion.verwerte(bereich);
			debug
			{
				write("Rückgabewert: ");
				schreibe_schön_wert(resultat);
				writeln("");
			}
		}
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return false;
	}
}

class Programm_BlockGlied : BlockGlied
{
	override public Wert verwerte(uint bereich)
	{
		return super.verwerte(0);
	}

	override public bool ist_vollständig()
	{
		return true;
	}
}

//MARK: FALLS
class Falls_BlockGlied : BlockGlied
{
	public Glied bedingung;

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
		write("}");
	}

	override public Wert verwerte(uint bereich)
	{
		Wert wert_bedingung = this.bedingung.verwerte(bereich);

		if (wert_bedingung.typ == WertTyp.WAHRHEIT && *cast(bool*) wert_bedingung.wert)
		{
			return super.verwerte(bereich);
		}

		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return true;
	}
}

class Falls_Sonst_BlockGlied : Falls_BlockGlied
{
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
		foreach (Glied aktion; sonst_aktionen)
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
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return true;
	}
}
