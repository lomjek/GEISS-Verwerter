module variablen.wert;

import std.conv : to;
import zahl;
import text;

import glied.wert_glied : WT_Glied;
import fehler.parse_fehler;

// @ {} [] # \ || != ~

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

immutable(dstring[WertTyp]) wertTypString = [
	WertTyp.INVALID: "variable"d,

	WertTyp.ZAHL: "zahl"d,
	WertTyp.GANZE_ZAHL: "gzahl"d,
	WertTyp.NATÜRLICHE_ZAHL: "nzahl"d,

	WertTyp.WAHRHEIT: "wahrheit"d,

	WertTyp.TEXT: "text"d,

	WertTyp.LISTE: "liste"d,

	WertTyp.FUNKTION: "funktion"d
];

immutable(dstring[][WertTyp]) multi_wort_wert_typ = [
	WertTyp.GANZE_ZAHL: ["ganze"d, "zahl"d],
	WertTyp.NATÜRLICHE_ZAHL: ["natürliche"d, "zahl"d]
];

//region Leser_Funktionen
WertTyp dstring_als_wt(dstring wort)
{
	foreach (WertTyp wt, dstring str; wertTypString)
	{
		if (str == wort)
			return wt;
	}

	return WertTyp.INVALID;
}

bool wort_ist_wert_typ(dstring wort)
{
	foreach (WertTyp wt, dstring str; wertTypString)
	{
		if (str == wort)
			return true;
	}

	foreach (WertTyp wt, immutable dstring[] strs; multi_wort_wert_typ)
	{
		if (strs[0] == wort)
			return true;
	}

	return false;
}

private pure
WertTyp erstelle_multi_wort_wert_typ(dstring[] wort_liste, ulong* wort_index)
{
	foreach (WertTyp wt, immutable dstring[] strs; multi_wort_wert_typ)
	{
		dstring[] ganzer_wt = [];
		for (ulong i = 0; i < multi_wort_wert_typ.length; i++)
		{
			ganzer_wt ~= wort_liste[*wort_index + i];
		}

		if (ganzer_wt == strs)
		{
			*wort_index += ganzer_wt.length - 1;
			return wt;
		}
	}

	return WertTyp.INVALID;
}

WT_Glied wort_als_wert_typ(dstring[] wort_liste, ulong* wort_index)
{
	WertTyp wt = erstelle_multi_wort_wert_typ(wort_liste, wort_index);

	if (wt == WertTyp.INVALID)
		wt = dstring_als_wt(wort_liste[*wort_index]);

	if (wt == WertTyp.INVALID)
		throw new Parse_Fehler(
			"Das Wort ist kein valides WertTyp " ~ wort_liste[*wort_index].to!string);

	return new WT_Glied(wt);
}
//endregion
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

public bool ist_wahr(Wert wert)
{
	if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
		return true;

	//TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

	return false;
}
