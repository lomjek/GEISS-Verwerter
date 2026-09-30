module wert.wert;

import wert.wert_typ;

import std.conv : to;
import zahl;
import text;

// @ {} [] # \ || != ~

// WERT
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
			Nzahl nz = *cast(Nzahl*) this.wert;
			wert_str = nz.als_string;
		}
		else if (this.typ == WertTyp.GANZE_ZAHL)
		{
			Gzahl gz = *cast(Gzahl*) this.wert;
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
			wert_str ~= (*cast(Text*) this.wert).str;
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

public bool ist_wahr(Wert wert)
{
	if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
		return true;

	//TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

	return false;
}
