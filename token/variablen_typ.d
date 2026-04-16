module token.variablen_typ;

// @ {} [] # \ || != ~

enum VariablenTyp
{
	INVALID,

	ZAHL,
	GANZE_ZAHL,
	NATÜRLICHE_ZAHL,

	WAHRHEIT,

	FARBE,

	AUSDRUCK
}

string[VariablenTyp] variablenTyp_strings;
string[] typ_präfixe = [
	"ganze",
	"natürliche"
];

static this()
{
	variablenTyp_strings[VariablenTyp.ZAHL] = "zahl";
	variablenTyp_strings[VariablenTyp.GANZE_ZAHL] = "ganze_zahl";
	variablenTyp_strings[VariablenTyp.NATÜRLICHE_ZAHL] = "natürliche_zahl";

	variablenTyp_strings[VariablenTyp.WAHRHEIT] = "wahrheit";

	variablenTyp_strings[VariablenTyp.FARBE] = "farbe";

	variablenTyp_strings[VariablenTyp.AUSDRUCK] = "ausdruck";
}
