module glied.wert_glied;

import std.stdio : write;
import std.conv : to;

import variablen.wert;
import zahl;
import liste;
import glied.glied;

import ext.prints;

// @ {} [] # \ || != ~

class Wert_Glied : Glied
{
	Wert wert;

	override public Wert verwerte(uint bereich)
	{
		return wert;
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	override public void schreibe_baum()
	{
		schreibe_schön_wert(wert);
	}

	override public string toString() const
	{
		return "G(WERT | " ~ wert.toString ~ ")";
	}

	this(Wert neuer_wert)
	{
		wert = neuer_wert;
	}

	this()
	{
		this.wert = Wert(WertTyp.INVALID, null);
	}
}

//MARK: Glied Liste 
class ListeWert_Glied : Wert_Glied
{
	Glied[] werte;

	override public Wert verwerte(uint bereich)
	{
		Wert*[] liste;

		foreach (Glied glied; this.werte)
		{
			liste ~= new Wert(glied.verwerte(bereich));
		}

		return Wert(WertTyp.LISTE, new Liste(true, WertTyp.INVALID, liste));
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	override public void schreibe_baum()
	{
		write("[LISTE]{");

		bool first_run = true;
		foreach (Glied glied; this.werte)
		{
			if (!first_run)
				write(", ");

			glied.schreibe_baum;

			first_run = false;
		}
		write("}");
	}

	override public string toString() const
	{
		string str = "G(LISTE | [";

		bool first_run = true;

		foreach (glied; werte)
		{
			if (!first_run)
				str ~= ", ";

			str ~= to!string(glied);

			first_run = false;
		}

		str ~= "]";
		return str;
	}

	this(Glied[] init_liste)
	{
		this.werte = init_liste;
	}
}
