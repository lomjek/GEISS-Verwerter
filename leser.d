module leser;

import std;

import token;
import token.variablen_typ;

// @ {} [] # \ || != ~

private enum Verifizierung
{
	ja,
	nein,
	nicht_ganz
}

private Verifizierung ist_schlüsselwort()
{
	return Verifizierung.nein;
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

private VariablenTyp vt_typ(string wort)
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
			*vt = wort.vt_typ;
			token_liste ~= Token(Token_Typ.var_typ, vt);
			writeln(wort.vt_typ);
			continue;
		}
		else if (wort.ist_vt == Verifizierung.nicht_ganz)
		{
			wort_präfix = wort ~ "_";
			continue;
		}
	}

	writeln(token_liste);

	return token_liste;
}
