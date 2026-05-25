module variablen.variable;

import variablen.wert;

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
	void* wert;
}
