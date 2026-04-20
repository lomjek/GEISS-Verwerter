module token.token;

import std;

// @ {} [] # \ || != ~

enum Token_Typ
{
	wert,
	operator,
	var_typ,
	var_name,
	schlussel_wort
}

struct Token
{
	Token_Typ typ;
	void* wert;
}
