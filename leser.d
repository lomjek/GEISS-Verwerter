module leser;

import std;

import ext.string;

import token.token;
import token.schlüsselwörter;
import token.variablen_typ;
import token.variable;
import token.operatoren;

// @ {} [] # \ || != ~

private enum Verifizierung
{
	ja,
	nein,
	nicht_ganz
}

// MARK: Schüsselwort 
private Verifizierung ist_sw(dchar[] wort)
{
	foreach (SchlüsselWort swort, dchar[] wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	return Verifizierung.nein;
}

private SchlüsselWort als_sw(dchar[] wort)
{
	foreach (SchlüsselWort swort, dchar[] wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return swort;
		}
	}

	return SchlüsselWort.INVALID;
}

// MARK: VariablenTyp
private Verifizierung ist_vt(dchar[] wort)
{
	foreach (VariablenTyp typ, dchar[] wert; variablenTyp_strings)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	foreach (dchar[] präfix; typ_präfixe)
	{
		if (präfix.strip == wort.strip)
		{
			return Verifizierung.nicht_ganz;
		}

	}

	return Verifizierung.nein;
}

private VariablenTyp als_vt(dchar[] wort)
{
	foreach (VariablenTyp typ, dchar[] wert; variablenTyp_strings)
	{
		if (wort.strip == wert.strip)
		{
			return typ;
		}
	}

	return VariablenTyp.INVALID;
}

// MARK: Wert - ist?
dchar[][] string_delims = [
	['\\', '\''], ['\\', '"'], ['\''], ['"']
];

private Verifizierung ist_string(dchar[] wort)
{
	foreach (dchar[] delim; string_delims)
	{
		if (wort.strip.startsWith(delim) && wort.length == delim.length)
		{
			return Verifizierung.nicht_ganz;
		}

		if (wort.strip.startsWith(delim) && wort.strip.endsWith(delim))
		{
			return Verifizierung.ja;
		}
		else if (wort.strip.startsWith(delim))
		{
			return Verifizierung.nicht_ganz;
		}
	}

	return Verifizierung.nein;
}

private bool ist_zahl(dchar[] wort)
{
	wort = wort.strip;
	try
	{
		to!int(wort);
		return true;
	}
	catch (ConvException e)
	{
		return false;
	}
}

private bool ist_wahrheit(dchar[] wort)
{
	if (wort == "wahr"d || wort == "falsch"d)
	{
		return true;
	}
	return false;
}

private Verifizierung ist_wert(dchar[] wort)
{
	if (wort.ist_zahl)
	{
		return Verifizierung.ja;
	}
	else if (wort.ist_string == Verifizierung.nein)
	{
		return wort.ist_string;
	}
	else if (wort.ist_wahrheit)
	{
		return Verifizierung.ja;
	}

	return Verifizierung.nein;
}

//MARK: Wert - als!
private Variable als_wert_string(dchar[] wort)
{
	if ((wort.startsWith("'") && wort.endsWith("'")) || (wort.startsWith('"') && wort.endsWith('"')))
	{
		wort = wort[1 .. $ - 1];
	}
	else if ((wort.startsWith("\\'") && wort.endsWith("\\'")) || (wort.startsWith("\\\"") && wort.endsWith(
			"\\\"")))
	{
		wort = wort[2 .. $ - 2];
	}

	dchar[]* str = (new dchar[][1]).ptr;
	*str = wort.dup;
	return Variable(VariablenTyp.AUSDRUCK, str);
}

private Variable als_wert_zahl(dchar[] wort)
{
	try
	{
		int zahl = to!int(wort);
		if (zahl >= 0)
		{
			uint* num = new uint;
			*num = to!uint(zahl);
			return Variable(VariablenTyp.NATÜRLICHE_ZAHL, num);
		}
		else
		{
			int* num = new int;
			*num = zahl;
			return Variable(VariablenTyp.GANZE_ZAHL, num);
		}
	}
	catch (ConvException e)
	{
		return Variable(VariablenTyp.INVALID, null);
	}
}

private Variable als_wert_wahrheit(dchar[] wort)
{
	bool* wahr;
	if (wort == "wahr"d)
	{
		*wahr = true;
	}
	else if (wort == "falsch"d)
	{
		*wahr = false;
	}
	else
	{
		return Variable(VariablenTyp.INVALID, null);
	}
	return Variable(VariablenTyp.WAHRHEIT, wahr);
}

private Variable als_wert(dchar[] wort)
{
	if (wort.ist_string == Verifizierung.ja)
	{
		return als_wert_string(wort);
	}
	else if (wort.ist_zahl)
	{
		return als_wert_zahl(wort);
	}

	return Variable(VariablenTyp.INVALID, null);
}

// MARK: operatoren
private bool ist_operator(dchar[] wort)
{
	if (wort.length > 1)
	{
		return false;
	}
	dchar op_char = wort[0];

	foreach (dchar chr; operatoren_chars.byValue)
	{
		if (chr == op_char)
		{
			return true;
		}
	}
	return false;
}

private OperatorenTyp als_operator(dchar[] wort)
{
	if (wort.length > 1)
	{
		return OperatorenTyp.INVALID;
	}

	dchar chr = wort[0];

	foreach (OperatorenTyp op, dchar op_char; operatoren_chars)
	{
		if (op_char == chr)
		{
			return op;
		}
	}

	return OperatorenTyp.INVALID;
}

// MARK: lese_linie
Token[] lese_linie(dchar[] linie, uint* fehlermeldungen)
{
	// Mache Platz vor und nach den Operatoren, damit sie aufgetrennt werden
	foreach (op; EnumMembers!OperatorenTyp)
	{
		dchar[] to_convert = [' ', operatoren_chars[op], ' '];
		linie = replaceAll(linie, operatoren_chars[op],
			to_convert);
	}

	Token[] token_liste;
	dchar[][] wort_liste = linie.split(" ");

	dchar[] wort_präfix;

	foreach (dchar[] wort; wort_liste)
	{
		wort = wort.strip;

		wort = wort_präfix ~ wort;
		wort_präfix = [];

		// Clean up
		if (wort.length == 0)
		{
			continue;
		}

		// VariablenTypen
		if (wort.ist_vt == Verifizierung.ja)
		{
			VariablenTyp* vt = new VariablenTyp;

			*vt = wort.als_vt;
			token_liste ~= Token(Token_Typ.var_typ, vt);
			continue;
		}
		else if (wort.ist_vt == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ "_";
			continue;
		}

		if (wort.ist_sw == Verifizierung.ja)
		{
			SchlüsselWort* sw = new SchlüsselWort;

			*sw = wort.als_sw;
			token_liste ~= Token(Token_Typ.schlussel_wort, sw);
			continue;
		}

		if (wort.ist_wert == Verifizierung.ja)
		{
			Variable* var = new Variable;
			*var = als_wert(wort);

			token_liste ~= Token(Token_Typ.wert, var);
			continue;
		}
		else if (wort.ist_wert == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ " ";
		}

		if (wort.ist_operator)
		{
			OperatorenTyp* op_typ = new OperatorenTyp;
			*op_typ = wort.als_operator;

			token_liste ~= Token(Token_Typ.operator, op_typ);
			continue;
		}

		// If none of the above treat as variable name
		dchar[]* v_name = (new dchar[][1]).ptr;
		*v_name = wort.dup;
		token_liste ~= Token(Token_Typ.var_name, v_name);
	}

	debug write("Token Liste: ");
	debug writeln(token_liste);

	ulong length = token_liste.length;

	for (uint i = 1; i < length - 1; i++) // Der erste Durchgang Zieht die Kommazahlen wieder zusammen.
	{
		if (token_liste[i - 1].typ == Token_Typ.wert &&
			token_liste[i + 1].typ == Token_Typ.wert &&
			token_liste[i].typ == Token_Typ.operator)
		{
			OperatorenTyp operator = *cast(OperatorenTyp*) token_liste[i].wert;
			Variable vorher = *cast(Variable*) token_liste[i - 1].wert;
			Variable naher = *cast(Variable*) token_liste[i + 1].wert;

			if ((operator == OperatorenTyp.PUNKT) &&
				(vorher.typ == VariablenTyp.GANZE_ZAHL ||
					vorher.typ == VariablenTyp.NATÜRLICHE_ZAHL) &&
				(naher.typ == VariablenTyp.GANZE_ZAHL ||
					naher.typ == VariablenTyp.NATÜRLICHE_ZAHL))
			{
				double deizimahlzahl;

				if (vorher.typ == VariablenTyp.GANZE_ZAHL)
				{
					int tmp = *cast(int*) vorher.wert;
					deizimahlzahl = tmp.to!double;
				}
				else if (vorher.typ == VariablenTyp.NATÜRLICHE_ZAHL)
				{
					uint tmp = *cast(uint*) vorher.wert;
					deizimahlzahl = tmp.to!double;
				}

				if (naher.typ == VariablenTyp.GANZE_ZAHL)
				{
					int tmp = *cast(int*) naher.wert;
					double tmp_2 = tmp / (tmp.to!string.length).to!double;
					deizimahlzahl += tmp_2;
				}
				else if (naher.typ == VariablenTyp.NATÜRLICHE_ZAHL)
				{
					uint tmp = *cast(uint*) naher.wert;
					double tmp_2 = tmp / (tmp.to!string.length).to!double;
					deizimahlzahl += tmp_2;
				}
				double* deizimahlzahl_heap = new double;
				*deizimahlzahl_heap = deizimahlzahl;
				Variable* heap_var = new Variable(VariablenTyp.ZAHL, deizimahlzahl_heap);
				token_liste[i - 1] = Token(Token_Typ.wert, heap_var);
				token_liste = token_liste.remove(i);
				token_liste = token_liste.remove(i);
				length -= 2;
			}
		}
	}

	length = token_liste.length; // Eigentlich wäre das hier nicht nötig, aber lieber sicher sein.

	for (uint i = 1; i < length; i++) // Der zweite Durchgang beachtet Minuszahlen
	{
		if (token_liste[i].typ == Token_Typ.wert && token_liste[i - 1].typ == Token_Typ
			.operator)
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
							OperatorenTyp nextOp = *cast(OperatorenTyp*) token_liste[i + 1]
								.wert;
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

	for (uint i = 1; i < length; i++) // Der dritte Durchlauf veränder <- zu Pfeilen.
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

	return token_liste;
}
