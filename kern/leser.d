module leser;

import ext.string;
import ext.prints;

import glied.glied;
import glied.wert_glied;
import glied.variablen_glied;
import glied.operation_glied;

import schlüsselwörter;
import operatoren;
import zahl;

import variablen.wert;

import core.memory;

import std.array;
import std.algorithm : startsWith, endsWith, remove, canFind, filter;
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

private nothrow Verifizierung ist_string(dstring wort)
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

private nothrow Verifizierung ist_wert(dstring wort)
{
	if (wort.ist_zahl)
	{
		return Verifizierung.ja;
	}
	else if (wort.ist_string != Verifizierung.nein)
	{
		return wort.ist_string;
	}
	else if (wort == "wahr"d || wort == "falsch"d)
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

private Wert als_wert_wahrheit(dstring wort)
{
	bool* wahr = new bool;
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
	else if (wort == "wahr"d || wort == "falsch"d)
	{
		return als_wert_wahrheit(wort);
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
Glied[] lese_linie(dstring linie)
{
	// Mache Platz vor und nach den Operatoren, damit sie aufgetrennt werden
	foreach (op; EnumMembers!OperatorenTyp)
	{
		dstring to_convert = [' ', operatoren_chars[op], ' '];
		linie = replaceAll(linie, operatoren_chars[op],
			to_convert);
	}

	Glied[] token_liste;

	dstring[] wort_liste = linie.split(" ");
	wort_liste = wort_liste.filter!(s => s.length > 0).array;

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

		if (wort_liste.length > i + 1) // Pfeile schon sofort zu Pfeilen machen
		{
			if (wort == "<" && (wort_liste[i + 1]).strip == "-")
			{
				token_liste ~= new OperationGlied(OperatorenTyp.RÜCK_PFEIL);
				wort_liste = wort_liste.remove(i + 1);
				wort_liste_length--;
				wort_liste[i] = " ";
				continue;
			}
		}

		if (wort_liste.length > i + 2)
		{
			if (wort.ist_zahl && wort_liste[i + 1] == ".")
			{
				Zahl z;

				if ((wort_liste[i + 2]).ist_zahl)
				{
					z = als_zahl(wort ~ wort_liste[i + 1] ~ wort_liste[i + 2]);

					wort_liste = wort_liste.remove(i + 2);
					wort_liste = wort_liste.remove(i + 1);
					wort_liste_length -= 2;
				}
				else
				{
					z = als_zahl(wort);

					wort_liste = wort_liste.remove(i + 1);
					wort_liste_length--;
				}

				wort_liste[i] = " ";
				token_liste ~= new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(z)));
				continue;
			}
		}

		// WertTypen
		if (wort.ist_vt == Verifizierung.ja)
		{
			token_liste ~= new WT_Glied(wort.als_vt);
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
					//TODO: Zweistellige Typen anschauen.
					throw new Error(
						"Muss sowieso noch die alten zweistelligen Typen anschauen...");
				}
			}
			continue;
		}

		if (wort.ist_sw == Verifizierung.ja)
		{
			token_liste ~= new SW_Glied(wort.als_sw);
			continue;
		}

		if (wort.ist_zahl)
		{
			token_liste ~= new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(als_zahl(wort))));
			continue;
		}

		if (wort.ist_wert == Verifizierung.ja)
		{
			token_liste ~= new Wert_Glied(wort.als_wert);
			continue;
		}
		else if (wort.ist_wert == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ " ";
			continue;
		}

		if (wort.ist_operator)
		{
			token_liste ~= new OperationGlied(wort.als_operator);
			continue;
		}

		// If none of the above treat as variable name
		token_liste ~= new Lese_Variable_Glied(wort);
	}

	debug
	{
		write("GL (1.0): ");
		set_pen_trait(TextTrait.fgGrey);
		writeln(token_liste);
		set_pen_trait();
	}

	ulong length = token_liste.length;

	//MARK: Aufräumen
	for (ulong i = 1; i < length; i++) // Der erste Durchgang beachtet Minuszahlen
	{
		if (token_liste[i].classinfo == Wert_Glied.classinfo &&
			token_liste[i - 1].classinfo == OperationGlied.classinfo)
		{
			Wert* var = &(cast(Wert_Glied) token_liste[i]).wert;
			OperatorenTyp op_typ = (cast(OperationGlied) token_liste[i - 1]).operationenTyp;

			// Falls nach dem Minus ein anderer Operator ist, lassen wir ihn liegen.
			if ((i > 1) && token_liste[i - 2].classinfo == Wert_Glied.classinfo)
			{
				continue;
			}

			if (op_typ == OperatorenTyp.MINUS)
			{
				if (var.typ == WertTyp.ZAHL)
				{
					Zahl* z = cast(Zahl*) var.wert;
					z.negativ = true;
					(cast(Wert_Glied) token_liste[i]).wert = Wert(WertTyp.ZAHL, new Zahl(*z));
					token_liste = token_liste.remove(i - 1);
					i--;
					length--;
					continue;
				}
			}
		}
	}

	debug
	{
		write("GL (1.1): ");
		set_pen_trait(TextTrait.fgGrey);
		writeln(token_liste);
		set_pen_trait();
	}

	return token_liste;
}
