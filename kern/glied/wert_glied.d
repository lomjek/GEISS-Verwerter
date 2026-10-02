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

class WT_Glied : Glied
{
	public WertTyp vt;

	override public Wert verwerte(uint bereich)
	{
		return Wert(WertTyp.INVALID, null);
	}

	override public void schreibe_baum()
	{
		write(vt.to!string);
	}

	override public bool ist_vollständig()
	{
		return false;
	}

	this(WertTyp vta)
	{
		this.vt = vta;
	}

	override string toString() const
	{
		return "G(VAR_TYP | " ~ this.vt.to!string ~ ")";
	}
}

