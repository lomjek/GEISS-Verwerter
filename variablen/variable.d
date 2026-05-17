module variablen.variable;

import variablen.wert_typ;

enum VariablenTyp
{
	FIX,
	VARIABEL,
	FUNKTION
}

struct Variable
{
	dchar[] identifier;
	VariablenTyp var_typ;
	WertTyp wert_typ;
	void* wert;
}
