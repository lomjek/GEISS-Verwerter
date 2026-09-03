module variablen.wert;

import std.conv : to;
import zahl;
import text;

struct Wert
{
	WertTyp typ;
	void* wert;

	this(WertTyp typ, void* wert)
	{
		this.typ = typ;
		this.wert = wert;
	}

	this(Wert nwert)
	{
		this.typ = nwert.typ;
		this.wert = nwert.wert;
	}

	string toString() const
	{
		string wert_str;
		if (this.typ == WertTyp.NATÜRLICHE_ZAHL)
		{
			NatürlicheZahl nz = *cast(NatürlicheZahl*) this.wert;
			wert_str = nz.als_string;
		}
		else if (this.typ == WertTyp.GANZE_ZAHL)
		{
			GanzeZahl gz = *cast(GanzeZahl*) this.wert;
			wert_str = gz.als_string;
		}
		else if (this.typ == WertTyp.ZAHL)
		{
			Zahl z = *cast(Zahl*) this.wert;
			wert_str = z.als_string;
		}
		else if (this.typ == WertTyp.TEXT)
		{
			wert_str = "\"";
			wert_str ~= (*cast(Text*) this.wert).payload;
			wert_str ~= "\"";
		}
		else if (this.typ == WertTyp.WAHRHEIT)
		{
			bool wahrheit = *cast(bool*) this.wert;
			wert_str = wahrheit ? "wahr" : "falsch";
		}
		else
			return "W(" ~ this.typ.to!string ~ ")";

		return "W(" ~ this.typ.to!string ~ " | " ~ wert_str ~ ")";
	}
}

// Wert Typ

enum WertTyp
{
	INVALID,

	ZAHL,
	GANZE_ZAHL,
	NATÜRLICHE_ZAHL,

	WAHRHEIT,

	TEXT,

	LISTE,

	FUNKTION
}

const WertTyp[] ZAHLEN_TYPEN = [
	WertTyp.GANZE_ZAHL,
	WertTyp.NATÜRLICHE_ZAHL,
	WertTyp.ZAHL
];

immutable dstring[WertTyp] wertTypString = [
	WertTyp.INVALID: "variable"d,

	WertTyp.ZAHL: "zahl"d,
	WertTyp.GANZE_ZAHL: "gzahl"d,
	WertTyp.NATÜRLICHE_ZAHL: "nzahl"d,

	WertTyp.WAHRHEIT: "wahrheit"d,

	WertTyp.TEXT: "text"d,

	WertTyp.LISTE: "liste"d,

	WertTyp.FUNKTION: "funktion"d
];

immutable dstring[dstring] typ_präfixe = [
	"ganze"d: "zahl"d,
	"natürliche"d: "zahl"d
];

public bool ist_wahr(Wert wert)
{
	if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
		return true;

	//TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

	return false;
}
