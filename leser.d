module leser;

import ext.string;
import ext.prints;

import token.token;
import token.schlüsselwörter;

import operatoren;

import variablen.wert;

import core.memory;
import std.algorithm : startsWith, endsWith, remove, canFind;
import std.string : strip;
import std.conv : to, ConvException;
import std.stdio : write, writeln;
import std.math : pow;
import std.array : split;
import std.traits : EnumMembers;

// @ {} [] # \ || != ~

private enum Verifizierung
{
	ja,
	nein,
	nicht_ganz
}

// MARK: Schüsselwort 
private Verifizierung ist_sw(dstring wort)
{
	foreach (SchlüsselWort swort, dstring wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	return Verifizierung.nein;
}

private SchlüsselWort als_sw(dstring wort)
{
	foreach (SchlüsselWort swort, dstring wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return swort;
		}
	}

	return SchlüsselWort.INVALID;
}

// MARK: WertTyp
private Verifizierung ist_vt(dstring wort)
{
	foreach (WertTyp typ, dstring wert; wertTypString)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	foreach (dstring präfix; typ_präfixe)
	{
		if (präfix.strip == wort.strip)
		{
			return Verifizierung.nicht_ganz;
		}

	}

	return Verifizierung.nein;
}

private WertTyp als_vt(dstring wort)
{
	foreach (WertTyp typ, dstring wert; wertTypString)
	{
		if (wort.strip == wert.strip)
		{
			return typ;
		}
	}

	return WertTyp.INVALID;
}

// MARK: Wert - ist?
dstring[] string_delims = [
	"\\\'"d, "\\\""d, "\'"d, "\""d
];

private Verifizierung ist_string(dstring wort)
{
	foreach (dstring delim; string_delims)
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

private bool ist_zahl(dstring wort)
{
	wort = wort.strip;
	try
	{
		to!uint(wort);
		return true;
	}
	catch (ConvException e)
	{
		return false;
	}
}

private bool ist_wahrheit(dstring wort)
{
	if (wort == "wahr"d || wort == "falsch"d)
	{
		return true;
	}
	return false;
}

private Verifizierung ist_wert(dstring wort)
{
	if (wort.ist_zahl)
	{
		return Verifizierung.ja;
	}
	else if (wort.ist_string != Verifizierung.nein)
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
private Wert als_wert_string(dstring wort)
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

	dstring* heapSlice = cast(dstring*) GC.malloc(dstring.sizeof);
	*heapSlice = wort;
	return Wert(WertTyp.TEXT, heapSlice);
}

private Wert als_wert_zahl(dstring wort)
{
	try
	{
		int zahl = to!uint(wort);
		uint* num = new uint;
		*num = to!uint(zahl);
		return Wert(WertTyp.NATÜRLICHE_ZAHL, num);
	}
	catch (ConvException e)
	{
		return Wert(WertTyp.INVALID, null);
	}
}

private Wert als_wert_wahrheit(dstring wort)
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
		return Wert(WertTyp.INVALID, null);
	}
	return Wert(WertTyp.WAHRHEIT, wahr);
}

private Wert als_wert(dstring wort)
{
	if (wort.ist_string == Verifizierung.ja)
	{
		return als_wert_string(wort);
	}
	else if (wort.ist_zahl)
	{
		return als_wert_zahl(wort);
	}

	return Wert(WertTyp.INVALID, null);
}

// MARK: operatoren
private bool ist_operator(dstring wort)
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

private OperatorenTyp als_operator(dstring wort)
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
Token[] lese_linie(dstring linie, uint* fehlermeldungen)
{
	// Mache Platz vor und nach den Operatoren, damit sie aufgetrennt werden
	foreach (op; EnumMembers!OperatorenTyp)
	{
		dstring to_convert = [' ', operatoren_chars[op], ' '];
		linie = replaceAll(linie, operatoren_chars[op],
			to_convert);
	}

	Token[] token_liste;
	dstring[] wort_liste = linie.split(" ");
	ulong wort_liste_length = wort_liste.length;
	dstring wort_präfix;

	for (ulong i = 0; i < wort_liste_length; i++)
	{
		dstring wort = wort_liste[i].strip;

		wort = wort_präfix ~ wort;
		wort_präfix = [];

		// Clean up
		if (wort.length == 0)
		{
			continue;
		}

		// WertTypen
		if (wort.ist_vt == Verifizierung.ja)
		{
			WertTyp* vt = new WertTyp;

			*vt = wort.als_vt;
			token_liste ~= Token(Token_Typ.var_typ, vt);
			continue;
		}
		else if (wort.ist_vt == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ "_";
			if (i < wort_liste_length - 1)
			{
				dstring neues_wort = wort_liste[i + 1];
				if (neues_wort != "zahl"d)
				{
					*fehlermeldungen = 10;
					return token_liste;
				}
			}
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
			Wert* var = new Wert;
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
		dstring* v_name = (new dstring[1]).ptr;
		*v_name = wort.dup;
		token_liste ~= Token(Token_Typ.var_name, v_name);
	}

	debug write("Token Liste: ");
	debug schreibe_token_liste(token_liste);

	ulong length = token_liste.length;

	//MARK: Aufräumen
	for (uint i = 1; i < length - 1; i++) // Der erste Durchgang Zieht die Kommazahlen wieder zusammen.
	{
		if (token_liste[i - 1].typ == Token_Typ.wert &&
			token_liste[i + 1].typ == Token_Typ.wert &&
			token_liste[i].typ == Token_Typ.operator)
		{
			OperatorenTyp operator = *cast(OperatorenTyp*) token_liste[i].wert;
			Wert vorher = *cast(Wert*) token_liste[i - 1].wert;
			Wert naher = *cast(Wert*) token_liste[i + 1].wert;

			if ((operator == OperatorenTyp.PUNKT) &&
				(vorher.typ == WertTyp.NATÜRLICHE_ZAHL) &&
				(naher.typ == WertTyp.NATÜRLICHE_ZAHL))
			{
				double deizimahlzahl;

				uint tmp = *cast(uint*) vorher.wert;
				deizimahlzahl = tmp.to!double;

				uint tmp_2 = *cast(uint*) naher.wert;
				double tmp_3 = tmp_2 / pow(10, (tmp_2.to!string.length)).to!double;
				deizimahlzahl += tmp_3;

				double* deizimahlzahl_heap = new double;
				*deizimahlzahl_heap = deizimahlzahl;
				Wert* heap_var = new Wert(WertTyp.ZAHL, deizimahlzahl_heap);
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
			Wert* var = cast(Wert*) token_liste[i].wert;
			OperatorenTyp op_typ = *cast(OperatorenTyp*) token_liste[i - 1].wert;

			if (i > 1)
			{
				if (token_liste[i - 2].typ == Token_Typ.wert)
				{
					// Falls der Minusoperator zwischen verschiedenen Typen funktionieren sollte, muss man das hier noch ändern.
					Wert* var_vorher = cast(Wert*) token_liste[i - 2].wert;
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
				if (var.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					uint oldValue = *cast(uint*) var.wert;
					int* newValue = new int;

					*newValue = cast(int) oldValue * -1;

					token_liste[i].wert = new Wert(WertTyp.GANZE_ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);

					length--;
					i--;
				}
				else if (var.typ == WertTyp.GANZE_ZAHL)
				{
					int oldValue = *cast(int*) var.wert;
					int* newValue = new int;

					*newValue = cast(int) oldValue * -1;

					token_liste[i].wert = new Wert(WertTyp.GANZE_ZAHL, newValue);
					token_liste = token_liste.remove(i - 1);

					length--;
					i--;
				}
				else if (var.typ == WertTyp.ZAHL)
				{
					double oldValue = *cast(double*) var.wert;
					double* newValue = new double;

					*newValue = cast(double) oldValue * -1;

					token_liste[i].wert = new Wert(WertTyp.ZAHL, newValue);
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

	debug write("Neue Token Liste: ");
	debug schreibe_token_liste(token_liste);

	return token_liste;
}
