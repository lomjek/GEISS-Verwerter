module glied.wert_glied;

import std.stdio : write;

import variablen.wert;

import glied.glied;

class Wert_Glied : Glied
{
	private Wert wert;

	this(Wert neuer_wert)
	{
		wert = neuer_wert;
	}

	override public Wert verwerte()
	{
		return wert;
	}

	public WertTyp typ()
	{
		return wert.typ;
	}

	override public void schreibe_baum()
	{
		//Ausdruck
		if (wert.typ == WertTyp.AUSDRUCK)
		{
			write(*cast(dchar[]*) this.wert.wert);
		}
		//Zahlen
		else if (wert.typ == WertTyp.NATÜRLICHE_ZAHL)
		{
			write(*cast(uint*) this.wert.wert);
		}
		else if (wert.typ == WertTyp.GANZE_ZAHL)
		{
			write(*cast(int*) this.wert.wert);
		}
		else if (wert.typ == WertTyp.ZAHL)
		{
			write(*cast(double*) this.wert.wert);
		}
		//Wahrheit
		else if (wert.typ == WertTyp.WAHRHEIT)
		{
			write(*cast(bool*) this.wert.wert);
		}

		// Die Implementation von Listen ist noch unbekannt
	}
}
