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

// MARK: wert
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
		to!double(wort);
		return true;
	}
	catch (ConvException e)
	{
		return false;
	}
}

private Verifizierung ist_wert(dchar[] wort)
{
	if (wort.ist_zahl)
	{
		return Verifizierung.ja;
	}

	if (wort.ist_string == Verifizierung.ja)
	{
		return Verifizierung.ja;
	}
	else if (wort.ist_string == Verifizierung.nicht_ganz)
	{
		return Verifizierung.nicht_ganz;
	}

	return Verifizierung.nein;
}

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
		double zahl = to!double(wort);
		if (zahl % 1 == 0)
		{
			if (zahl >= 0)
			{
				uint* num = new uint;
				*num = to!uint(zahl);
				return Variable(VariablenTyp.NATÜRLICHE_ZAHL, num);
			}
			else
			{
				int* num = new int;
				*num = to!int(zahl);
				return Variable(VariablenTyp.GANZE_ZAHL, num);
			}
		}
		else
		{
			double* num = new double;
			*num = zahl;
			return Variable(VariablenTyp.ZAHL, num);
		}
	}
	catch (ConvException e)
	{
		return Variable(VariablenTyp.INVALID, null);
	}
}

private Variable als_wert(dchar[] wort)
{
	if (wort.ist_string == Verifizierung.ja)
	{
		return als_wert_string(wort);
	}
	else if (wort.ist_zahl)
	{

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

	return token_liste;
}
