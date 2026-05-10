module baum_generator;

import token.token;
import token.variable;
import token.variablen_typ;
import token.operatoren;

import glied.glied;
import glied.wert_glied;
import glied.operation_glied;

import std.algorithm : remove, canFind;
import std.stdio : writeln, write;

Glied generiere_baum(Token[] token_liste)
{
	Glied[] glieder_liste = [];

	//TODO: Schauen, dass alle Blocks geschlossen sind.

	foreach (Token token; token_liste)
	{
		if (token.wert == null)
		{
			throw new Exception("Es hat keinen wert!!!");
		}

		if (token.typ == Token_Typ.wert)
		{
			Variable var = *cast(Variable*) token.wert;
			glieder_liste ~= new Wert_Glied(var);
		}
		else if (token.typ == Token_Typ.operator)
		{
			OperatorenTyp op_typ = *cast(OperatorenTyp*) token.wert;
			glieder_liste ~= new OperationGlied(op_typ);
		}
	}

	debug write("Rohe Gliederliste: ");
	debug writeln(glieder_liste);

	ulong arr_length = glieder_liste.length;
	for (ulong i = 0; i < arr_length; i++)
	{
		Glied glied = glieder_liste[i];

		if (glied.classinfo == Wert_Glied.classinfo)
		{
			continue;
		}

		if (glied.classinfo == OperationGlied.classinfo)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;

			if (i > 0 && i < (arr_length - 1))
			{
				Glied gl1 = glieder_liste[i - 1];
				Glied gl2 = glieder_liste[i + 1];
				if ((gl1.classinfo == Wert_Glied.classinfo) &&
					(gl2.classinfo == Wert_Glied.classinfo))
				{
					op_glied.werte ~= gl1;
					op_glied.werte ~= gl2;

					glieder_liste[i] = op_glied;
					glieder_liste = glieder_liste.remove(i + 1);
					glieder_liste = glieder_liste.remove(i - 1);
					arr_length -= 2;
					continue;
				}
				else
				{
					writeln("Fehler? : Parse Operationen Glied und nicht zwei Werte nebenan.");
				}
			}
		}
	}

	debug glieder_liste[0].schreibe_baum;
	debug write("\n");

	return glieder_liste[0];
}
