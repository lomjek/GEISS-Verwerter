module baum_generator;

import token.token;
import token.variable;
import token.variablen_typ;
import token.operatoren;

import glied.glied;
import glied.wert_glied;

import std.algorithm : remove, canFind;
import std.stdio : writeln, write;

Glied generiere_baum(Token[] token_liste)
{
	return new Wert_Glied(Variable(VariablenTyp.INVALID, null));
}
