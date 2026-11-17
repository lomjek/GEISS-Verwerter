module variablen.variable;

import wert;
import ext.prints : Str_conv_typ;
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
    str ~= wert.wandel.als_string((*cast(Wert*) var.wert), Str_conv_typ.AUSGABE); //TODO: Muss parameter werden
  }
  else
  {
    str ~= "unknown";
  }

  return str ~ ")";
}
