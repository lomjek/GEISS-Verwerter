module token.variablen_typ;

import ext.string : dchar_from_string;

// @ {} [] # \ || != ~

enum VariablenTyp
{
	INVALID,

	ZAHL,
	GANZE_ZAHL,
	NATÜRLICHE_ZAHL,

	WAHRHEIT,

	FARBE,

	AUSDRUCK,

	LISTE
}

dchar[][VariablenTyp] variablenTyp_strings;
dchar[][] typ_präfixe = [
	['g', 'a', 'n', 'z', 'e'],
	['n', 'a', 't', 'ü', 'r', 'l', 'i', 'c', 'h', 'e']
];

static this()
{
	variablenTyp_strings[VariablenTyp.ZAHL] = "zahl".dchar_from_string;
	variablenTyp_strings[VariablenTyp.GANZE_ZAHL] = "ganze_zahl".dchar_from_string;
	variablenTyp_strings[VariablenTyp.NATÜRLICHE_ZAHL] = "natürliche_zahl".dchar_from_string;

	variablenTyp_strings[VariablenTyp.WAHRHEIT] = "wahrheit".dchar_from_string;

	variablenTyp_strings[VariablenTyp.FARBE] = "farbe".dchar_from_string;

	variablenTyp_strings[VariablenTyp.AUSDRUCK] = "ausdruck".dchar_from_string;

	variablenTyp_strings[VariablenTyp.LISTE] = "liste".dchar_from_string;
}
