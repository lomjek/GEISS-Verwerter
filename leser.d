module leser;

import std;

import token.token;
import token.schlüsselwörter;
import token.variablen_typ;

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
			SchlüsselWort* sw = new SchlüsselWort;
			*sw = wort.als_sw;
			token_liste ~= Token(Token_Typ.schlussel_wort, sw);
			writeln(wort.als_sw);
			continue;
		}
	}

	writeln(token_liste);

	return token_liste;
}
