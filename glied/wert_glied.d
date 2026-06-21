module glied.wert_glied;

import std.stdio : write;
import std.conv : to;

import variablen.wert;
import zahl;
import glied.glied;

import ext.prints;

class Wert_Glied : Glied
{
	Wert wert;

	this(Wert neuer_wert)
	{
		wert = neuer_wert;
	}

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
}
