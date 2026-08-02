module glied.block_glied;

import glied.glied;

import variablen.wert;

import ext.prints;

import std.stdio : writeln, write;
import std.conv : to;

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

	override string toString() const
	{
		return "G(BLOCK | " ~ aktionen.length.to!string ~ ")";
	}

	this()
	{
	}

	this(Glied[] glieder_liste)
	{
		this.aktionen = glieder_liste;
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

	override string toString() const
	{
		return "G(PROGRAMM | " ~ aktionen.length.to!string ~ ")";
	}
}

//MARK: FALLS
class Falls_BlockGlied : BlockGlied
{
	public Glied bedingung;

	override public void schreibe_baum()
	{
		write("[FALLS ");
		if (bedingung !is null)
			bedingung.schreibe_baum();
		write("]{");
		schreibe_glied_liste(aktionen);
		write("}");
	}

	override public Wert verwerte(uint bereich)
	{
		Wert wert_bedingung = this.bedingung.verwerte(bereich);
		if (wert_bedingung.ist_wahr)
		{
			verwerte_glieder_liste(bereich, this.aktionen);
		}

		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return (bedingung !is null) && (aktionen.length !is 0);
	}

	override string toString() const
	{
		return "G(FALLS | " ~ aktionen.length.to!string ~ ")";
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
		return aktionen.length > 0;
	}

	override string toString() const
	{
		return "G(SONST | " ~ (aktionen.length)
			.to!string ~ ")";
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
		Wert wert_bedingung = bedingung.verwerte(bereich);

		if (wert_bedingung.ist_wahr)
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
		return (bedingung !is null) && (aktionen.length !is 0) && (sonst_aktionen.length != 0);
	}

	this(Falls_BlockGlied f_bgl, Sonst_BlockGlied s_bgl)
	{
		this.aktionen = f_bgl.aktionen;
		this.bedingung = f_bgl.bedingung;
		this.sonst_aktionen = s_bgl.aktionen;
	}

	override string toString() const
	{
		return "G(FALLS / SONST | " ~ (aktionen.length)
			.to!string ~ "/" ~ (sonst_aktionen.length).to!string ~ ")";
	}
}

//MARK: SOLANGE
class Solange_BlockGlied : BlockGlied
{
	Glied bedingung;

	override public void schreibe_baum()
	{
		write("[SOLANGE ");
		bedingung.schreibe_baum();
		write("]{");
		schreibe_glied_liste(this.aktionen);
		write("}");
	}

	private bool erfüllt(uint bereich)
	{
		Wert wert_bedingung = bedingung.verwerte(bereich);
		return wert_bedingung.ist_wahr;
	}

	override public Wert verwerte(uint bereich)
	{
		while (erfüllt(bereich))
		{
			verwerte_glieder_liste(bereich, aktionen);
		}
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return (bedingung !is null) && (aktionen.length !is 0);
	}

	override string toString() const
	{
		return "G(SOLANGE | " ~ aktionen.length.to!string ~ ")";
	}
}
