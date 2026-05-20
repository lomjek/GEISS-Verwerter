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

dchar[][WertTyp] variablenTyp_strings;
dchar[][] typ_präfixe = [
	['g', 'a', 'n', 'z', 'e'],
	['n', 'a', 't', 'ü', 'r', 'l', 'i', 'c', 'h', 'e']
];

static this()
{
	variablenTyp_strings[WertTyp.ZAHL] = "zahl".dchar_from_string;
	variablenTyp_strings[WertTyp.GANZE_ZAHL] = "ganze_zahl".dchar_from_string;
	variablenTyp_strings[WertTyp.NATÜRLICHE_ZAHL] = "natürliche_zahl".dchar_from_string;

	variablenTyp_strings[WertTyp.WAHRHEIT] = "wahrheit".dchar_from_string;

	variablenTyp_strings[WertTyp.FARBE] = "farbe".dchar_from_string;

	variablenTyp_strings[WertTyp.TEXT] = "text".dchar_from_string;

	variablenTyp_strings[WertTyp.LISTE] = "liste".dchar_from_string;
}
