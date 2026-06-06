module glied.wert_glied;

import std.stdio : write;

import variablen.wert;
import zahl;
import glied.glied;

class Wert_Glied : Glied
{
	private Wert wert;

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
		//Ausdruck
		if (wert.typ == WertTyp.TEXT)
		{
			write(*cast(dchar[]*) this.wert.wert);
		}
		//Zahlen
		else if (wert.typ == WertTyp.NATÜRLICHE_ZAHL)
		{
			write((*cast(NatürlicheZahl*) wert.wert).als_string);
		}
		else if (wert.typ == WertTyp.GANZE_ZAHL)
		{
			write((*cast(GanzeZahl*) wert.wert).als_string);
		}
		else if (wert.typ == WertTyp.ZAHL)
		{
			write((*cast(Zahl*) wert.wert).als_string);
		}
		//Wahrheit
		else if (wert.typ == WertTyp.WAHRHEIT)
		{
			write(*cast(bool*) this.wert.wert);
		}

		// Die Implementation von Listen ist noch unbekannt
	}
}
