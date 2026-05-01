module glied.wert_glied;

import std.stdio : write;

import token.variable;
import token.variablen_typ;

import glied.glied;

class Wert_Glied : Glied
{
	Variable wert;

	this(Variable neuer_wert)
	{
		wert = neuer_wert;
	}

	override public Variable verwerte()
	{
		return wert;
	}

	override public void schreibe_baum()
	{
		//Ausdruck
		if (wert.typ == VariablenTyp.AUSDRUCK)
		{
			write(*cast(dchar[]*) this.wert.wert);
		}
		//Zahlen
		else if (wert.typ == VariablenTyp.NATÜRLICHE_ZAHL)
		{
			write(*cast(uint*) this.wert.wert);
		}
		else if (wert.typ == VariablenTyp.GANZE_ZAHL)
		{
			write(*cast(int*) this.wert.wert);
		}
		else if (wert.typ == VariablenTyp.ZAHL)
		{
			write(*cast(double*) this.wert.wert);
		}
		//Wahrheit
		else if (wert.typ == VariablenTyp.WAHRHEIT)
		{
			write(*cast(bool*) this.wert.wert);
		}

		// Die Implementation von Listen ist noch unbekannt
	}
}
