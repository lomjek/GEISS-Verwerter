module variablen.wert;

import ext.string : dchar_from_string;

struct Wert
{
	WertTyp typ;
	void* wert;
}

// Wert Typ

enum WertTyp
{
	INVALID,

	ZAHL,
	GANZE_ZAHL,
	NATÜRLICHE_ZAHL,

	WAHRHEIT,

	FARBE,

	TEXT,

	LISTE
}

const WertTyp[] ZAHLEN_TYPEN = [
	WertTyp.GANZE_ZAHL,
	WertTyp.NATÜRLICHE_ZAHL,
	WertTyp.ZAHL
];

dstring[WertTyp] wertTypString = [
	WertTyp.INVALID: "invalid"d,

	WertTyp.ZAHL: "zahl"d,
	WertTyp.GANZE_ZAHL: "gzahl"d,
	WertTyp.NATÜRLICHE_ZAHL: "nzahl"d,

	WertTyp.WAHRHEIT: "wahrheit"d,

	WertTyp.FARBE: "farbe"d,

	WertTyp.TEXT: "text"d,

	WertTyp.LISTE: "liste"d
];

immutable dstring[dstring] typ_präfixe = [
	"ganze"d: "zahl"d,
	"natürliche"d: "zahl"d
];
