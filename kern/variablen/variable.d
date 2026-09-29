module variablen.variable;

import variablen.wert;

import ext.prints;
import ext.algorithm : contains;

import std.conv : to;

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

public string als_string(Variable var)
{
	string str = "V(";
	str ~= var.identifier.to!string;
	str ~= " | ";
	str ~= var.var_typ.to!string;
	str ~= " | ";

	if ([VariablenTyp.VARIABEL, VariablenTyp.FIX].contains(var.var_typ))
	{
		str ~= als_schön_string(*cast(Wert*) var.wert);
	}
	else
	{
		str ~= "unknown";
	}

	return str ~ ")";
}
