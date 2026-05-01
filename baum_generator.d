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
	for (int i = 1; i < token_liste.length; i++)
	{
		if (token_liste[i].typ == Token_Typ.wert && token_liste[i - 1].typ == Token_Typ.operator)
		{
			Variable* var = cast(Variable*) token_liste[i].wert;
			OperatorenTyp op_typ = *cast(OperatorenTyp*) token_liste[i - 1].wert;

			if (op_typ == OperatorenTyp.MINUS)
			{
				if (var.typ == VariablenTyp.NATÜRLICHE_ZAHL)
				{
					uint oldValue = *cast(uint*) var.wert;
					int* newValue = new int;
					*newValue = cast(int) oldValue * -1;

					token_liste[i].wert = new Variable(VariablenTyp.GANZE_ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);
					i--;
				}
			}
		}
	}

	debug write("Neue Token Liste:");
	debug writeln(token_liste);

	return new Wert_Glied(Variable(VariablenTyp.INVALID, null));
}
