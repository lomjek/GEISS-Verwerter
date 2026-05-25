module glied.glied;

import std.stdio : write;

import variablen.wert;

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
}
