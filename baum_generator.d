module baum_generator;

import token.token;
import token.variable;
import token.operatoren;

import glied.glied;
import glied.wert_glied;
import glied.operation_glied;

import variablen.wert_typ;

import std.algorithm : remove, canFind;
import std.stdio : writeln, write;

private enum Operation_priorities
{
	INVALID,

	SETZE_VARIABLE,

	PLUS_MINUS,
	MAL_DURCH,
	HOCH,

}

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
	while (arr_length > 1)
	{
		// Finde die Anwendung mit max. Prioriäten;
		Operation_priorities max_priority_operation = Operation_priorities.INVALID;
		ulong max_priority_index = 0;
		for (ulong i = 0; i < arr_length; i++)
		{
			if (glieder_liste[i].classinfo == OperationGlied.classinfo)
			{
				OperationGlied opg = cast(OperationGlied) glieder_liste[i];
				if (opg.populated)
					continue;

				if ([OperatorenTyp.PLUS, OperatorenTyp.MINUS]
					.canFind(opg.operationenTyp) &&
					max_priority_operation < Operation_priorities.PLUS_MINUS)
				{
					max_priority_operation = Operation_priorities.PLUS_MINUS;
					max_priority_index = i;
				}
				else if ([OperatorenTyp.MAL, OperatorenTyp.GETEILT]
					.canFind(opg.operationenTyp) &&
					max_priority_operation < Operation_priorities.MAL_DURCH)
				{
					max_priority_operation = Operation_priorities.MAL_DURCH;
					max_priority_index = i;
				}
				else if (opg.operationenTyp == OperatorenTyp.HOCH &&
					max_priority_operation < Operation_priorities.HOCH)
				{
					max_priority_operation = Operation_priorities.HOCH;
					max_priority_index = i;
				}
			}
		}

		Glied glied = glieder_liste[max_priority_index];

		debug writeln(max_priority_index, max_priority_operation);

		if (glied.classinfo == Wert_Glied.classinfo)
		{
			continue;
		}

		if (glied.classinfo == OperationGlied.classinfo)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;

			if (max_priority_index > 0 && max_priority_index < (arr_length - 1))
			{
				Glied gl1 = glieder_liste[max_priority_index - 1];
				Glied gl2 = glieder_liste[max_priority_index + 1];
				// Falls die Operationen nicht immer die zwei Objekte daneben einnehmen sollen, muss hier ein if  Block hin
				op_glied.werte ~= gl1;
				op_glied.werte ~= gl2;
				op_glied.populated = true;

				glieder_liste[max_priority_index] = op_glied;
				glieder_liste = glieder_liste.remove(max_priority_index + 1);
				glieder_liste = glieder_liste.remove(max_priority_index - 1);
				arr_length -= 2;
				continue;
			}
		}
	}

	debug glieder_liste[0].schreibe_baum;
	debug write("\n");

	return glieder_liste[0];
}
