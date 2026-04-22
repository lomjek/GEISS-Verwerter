module leser;

import std;

import token.token;
import token.schlüsselwörter;
import token.variablen_typ;
import token.variable;

// @ {} [] # \ || != ~

private enum Verifizierung
{
	ja,
	nein,
	nicht_ganz
}

// MARK: Schüsselwort 
private Verifizierung ist_sw(string wort)
{
	foreach (SchlüsselWort swort, string wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	return Verifizierung.nein;
}

private SchlüsselWort als_sw(string wort)
{
	foreach (SchlüsselWort swort, string wert; schlüsselWort_dict)
	{
		if (wort.strip == wert.strip)
		{
			return swort;
		}
	}

	return SchlüsselWort.INVALID;
}

// MARK: VariablenTyp
private Verifizierung ist_vt(string wort)
{
	foreach (VariablenTyp typ, string wert; variablenTyp_strings)
	{
		if (wort.strip == wert.strip)
		{
			return Verifizierung.ja;
		}
	}

	foreach (string präfix; typ_präfixe)
	{
		if (präfix.strip == wort.strip)
		{
			return Verifizierung.nicht_ganz;
		}

	}

	return Verifizierung.nein;
}

private VariablenTyp als_vt(string wort)
{
	foreach (VariablenTyp typ, string wert; variablenTyp_strings)
	{
		if (wort.strip == wert.strip)
		{
			return typ;
		}
	}

	return VariablenTyp.INVALID;
}

// MARK: wert
const static string[4] string_delims = ["\\'", "\\\"", "'", "\""];

private Verifizierung ist_string(string wort)
{
	foreach (string delim; string_delims)
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

private bool ist_zahl(string wort)
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

private Verifizierung ist_wert(string wort)
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

private Variable als_wert_string(string wort)
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

	string* str = (new string[](wort.length)).ptr;
	*str = wort;
	writeln(*str);
	return Variable(VariablenTyp.AUSDRUCK, str);
}

private Variable als_wert_zahl(string wort)
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

private Variable als_wert(string wort)
{
	wort = wort.strip;
	if (wort.ist_string == Verifizierung.ja)
	{
		return als_wert_string(wort);
	}
	else if (wort.ist_zahl)
	{

	}

	return Variable(VariablenTyp.INVALID, null);
}

// MARK: lese_linie
Token[] lese_linie(string linie, uint* fehlermeldungen)
{
	Token[] token_liste;
	string[] wort_liste = linie.split(" ");

	string wort_präfix = "";

	foreach (string wort; wort_liste)
	{
		wort = wort_präfix ~ wort;
		wort_präfix = "";

		if (wort.ist_vt == Verifizierung.ja)
		{
			VariablenTyp* vt = new VariablenTyp;

			*vt = wort.als_vt;
			token_liste ~= Token(Token_Typ.var_typ, vt);
			writeln(wort.als_vt);
			continue;
		}
		else if (wort.ist_vt == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ "_";
			continue;
		}

		if (wort.ist_sw == Verifizierung.ja)
		{
			wort_präfix = "";
			SchlüsselWort* sw = new SchlüsselWort;

			*sw = wort.als_sw;
			token_liste ~= Token(Token_Typ.schlussel_wort, sw);
			writeln(wort.als_sw);
			continue;
		}

		if (wort.ist_wert == Verifizierung.ja)
		{
			wort_präfix = "";
			Variable* var = new Variable;
			*var = als_wert(wort);

			token_liste ~= Token(Token_Typ.wert, var);

			writeln(als_wert(wort));
			continue;
		}
		else if (wort.ist_wert == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ " ";
		}
	}

	writeln(token_liste);

	return token_liste;
}
