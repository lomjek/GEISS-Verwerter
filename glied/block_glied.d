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
		write("[BLOCK]{");
		schreibe_glied_liste(this.aktionen);
		write("}");
	}

	protected void schreibe_glied_liste(Glied[] glied_liste)
	{
		bool first = true;
		foreach (Glied aktion; glied_liste)
		{
			if (!first)
				write(", ");
			aktion.schreibe_baum;
			first = false;
		}

	}

	override public Wert verwerte(uint bereich)
	{
		verwerte_glieder_liste(bereich, this.aktionen);
		return Wert(WertTyp.INVALID, null);
	}

	public void verwerte_glieder_liste(uint bereich, Glied[] aktionen)
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
	}

	override public bool ist_vollständig()
	{
		return false;
	}
}

class Programm_BlockGlied : BlockGlied
{
	override public Wert verwerte(uint bereich = 0)
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
		schreibe_glied_liste(aktionen);
		write("}");
	}

	protected bool ist_bedingung_erfüllt(uint bereich)
	{
		Wert wert_bedingung = this.bedingung.verwerte(bereich);

		if (wert_bedingung.typ == WertTyp.WAHRHEIT && *cast(bool*) wert_bedingung.wert)
			return true;

		return false;
	}

	override public Wert verwerte(uint bereich)
	{
		if (ist_bedingung_erfüllt(bereich))
		{
			verwerte_glieder_liste(bereich, this.aktionen);
		}

		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return true;
	}
}

class Sonst_BlockGlied : BlockGlied
{
	override public void schreibe_baum()
	{
		write("(Sonst_Block) INVALID");
	}

	override public Wert verwerte(uint bereich)
	{
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return false;
	}
}

class Falls_Sonst_BlockGlied : Falls_BlockGlied
{
	public Glied[] sonst_aktionen;

	override public void schreibe_baum()
	{
		write("[FALLS ");
		bedingung.schreibe_baum();
		write("]{{");
		schreibe_glied_liste(this.aktionen);
		write("} / {");
		schreibe_glied_liste(this.sonst_aktionen);
		write("}}");
	}

	override public Wert verwerte(uint bereich)
	{
		if (ist_bedingung_erfüllt(bereich))
		{
			verwerte_glieder_liste(bereich, aktionen);
		}
		else
		{
			verwerte_glieder_liste(bereich, sonst_aktionen);
		}

		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	this(Falls_BlockGlied f_bgl, Sonst_BlockGlied s_bgl)
	{
		this.aktionen = f_bgl.aktionen;
		this.bedingung = f_bgl.bedingung;
		this.sonst_aktionen = s_bgl.aktionen;
	}
}
