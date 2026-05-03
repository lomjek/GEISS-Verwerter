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
	// Erste Runde: - 3 wird zu -3.
	ulong length = token_liste.length;
	for (uint i = 1; i < length; i++)
	{
		if (token_liste[i].typ == Token_Typ.wert && token_liste[i - 1].typ == Token_Typ.operator)
		{
			Variable* var = cast(Variable*) token_liste[i].wert;
			OperatorenTyp op_typ = *cast(OperatorenTyp*) token_liste[i - 1].wert;

			if (i > 1)
			{
				if (token_liste[i - 2].typ == Token_Typ.wert)
				{
					// Falls der Minusoperator zwischen verschiedenen Typen funktionieren sollte, muss man das hier noch ändern.
					Variable* var_vorher = cast(Variable*) token_liste[i - 2].wert;
					if (ZAHLEN_TYPEN.canFind(var_vorher.typ))
					{
						continue;
					}

				}

				if (token_liste[i - 2].typ == Token_Typ.operator)
				{
					// Falls das Minus der Teil eines Pfeiles ist, nicht aber einer Liste.
					OperatorenTyp prevOp = *cast(OperatorenTyp*) token_liste[i - 2].wert;

					if (prevOp == OperatorenTyp.SPITZE_KLAMMER_AUF)
					{
						bool isValidSequence = false;

						if (i + 1 < length && token_liste[i + 1].typ == Token_Typ.operator)
						{
							OperatorenTyp nextOp = *cast(OperatorenTyp*) token_liste[i + 1].wert;
							if (nextOp == OperatorenTyp.SPITZE_KLAMMER_ZU || nextOp == OperatorenTyp
								.KOMMA)
							{
								isValidSequence = true;
							}
						}

						if (!isValidSequence)
						{
							continue;
						}
					}
				}
			}

			if (op_typ == OperatorenTyp.MINUS)
			{
				if (var.typ == VariablenTyp.NATÜRLICHE_ZAHL)
				{
					uint oldValue = *cast(uint*) var.wert;
					int* newValue = new int;
					*newValue = cast(int) oldValue * -1;

					token_liste[i].wert = new Variable(VariablenTyp.GANZE_ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);

					length--;
					i--;
				}
				else if (var.typ == VariablenTyp.GANZE_ZAHL)
				{
					int oldValue = *cast(int*) var.wert;
					int* newValue = new int;
					*newValue = cast(int) oldValue * -1;

					token_liste[i].wert = new Variable(VariablenTyp.GANZE_ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);

					length--;
					i--;
				}
				else if (var.typ == VariablenTyp.ZAHL)
				{
					double oldValue = *cast(double*) var.wert;
					double* newValue = new double;
					*newValue = cast(double) oldValue * -1;

					token_liste[i].wert = new Variable(VariablenTyp.ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);

					length--;
					i--;
				}
			}
		}
	}

	length = token_liste.length; // Eigentlich wäre das hier nicht nötig, aber lieber sicher sein.

	for (uint i = 1; i < length; i++)
	{
		if (token_liste[i].typ == Token_Typ.operator &&
			token_liste[i - 1].typ == Token_Typ.operator)
		{
			OperatorenTyp typ_1 = *cast(OperatorenTyp*) token_liste[i - 1].wert;
			OperatorenTyp typ_2 = *cast(OperatorenTyp*) token_liste[i].wert;
			if ((typ_1 == OperatorenTyp.SPITZE_KLAMMER_AUF) && (typ_2 == OperatorenTyp.MINUS))
			{
				OperatorenTyp* op_typ = new OperatorenTyp;
				*op_typ = OperatorenTyp.RÜCK_PFEIL;
				token_liste[i] = Token(Token_Typ.operator, op_typ);

				token_liste = token_liste.remove(i - 1);
				length--;
				i--;
			}
		}
	}

	debug write("Neue Token Liste:");
	debug writeln(token_liste);

	return new Wert_Glied(Variable(VariablenTyp.INVALID, null));
}
