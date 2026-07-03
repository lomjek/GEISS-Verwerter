module glied.glied;

import std.stdio : write;
import std.conv : to;

import variablen.wert;
import variablen.variable;
import schlüsselwörter;

// @ {} [] # \ || != ~

abstract class Glied
{
	abstract public Wert verwerte(uint bereich);
	abstract public void schreibe_baum();
	abstract public bool ist_vollständig();
}

class InvalidGlied : Glied
{
	override public Wert verwerte(uint bereich)
	{
		return Wert(WertTyp.INVALID, null);
	}

	override public void schreibe_baum()
	{
		write("INVALID");
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	override string toString() const
	{
		return "G(INVALID)";
	}
}

class SW_Glied : Glied
{
	public SchlüsselWort sw;

	override public Wert verwerte(uint bereich)
	{
		return Wert(WertTyp.INVALID, null);
	}

	override public void schreibe_baum()
	{
		write(sw.to!string);
	}

	override public bool ist_vollständig()
	{
		return false;
	}

	this(SchlüsselWort swa)
	{
		this.sw = swa;
	}

	override string toString() const
	{
		return "G(SCHLÜSSELWORT | " ~ this.sw.to!string ~ ")";
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
