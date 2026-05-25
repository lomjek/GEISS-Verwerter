module variablen.variable;

import variablen.wert;

enum VariablenTyp
{
	INVALID,
	FIX,
	VARIABEL,
	FUNKTION
}

struct Variable
{
	dstring identifier;
	VariablenTyp var_typ;
	void* wert;
}
