module ext.prints;

import operatoren : OperatorenTyp;

import token.token;

import variablen.wert;

import std.stdio : write, writeln;

// @ {} [] # \ || != ~

enum TextTrait : string
{
	reset = "\033[0m",
	bold = "\033[1m",
	underline = "\033[4m",

	fgBlack = "\033[30m",
	fgRed = "\033[31m",
	fgGreen = "\033[32m",
	fgYellow = "\033[33m",
	fgBlue = "\033[34m",
	fgMagenta = "\033[35m",
	fgCyan = "\033[36m",
	fgWhite = "\033[37m",
	fgGrey = "\033[90m",

	bgBlack = "\033[40m",
	bgRed = "\033[41m",
	bgGreen = "\033[42m",
	bgYellow = "\033[43m",
	bgBlue = "\033[44m",
	bgMagenta = "\033[45m",
	bgCyan = "\033[46m",
	bgWhite = "\033[47m"
}

void set_pen_trait(TextTrait tt)
{
	write(cast(string) tt);
}

void schreibe_schön_wert(Wert wert)
{
	if (wert.typ == WertTyp.NATÜRLICHE_ZAHL)
		write(*cast(uint*) wert.wert);
	else if (wert.typ == WertTyp.GANZE_ZAHL)
		write(*cast(int*) wert.wert);
	else if (wert.typ == WertTyp.ZAHL)
		write(*cast(double*) wert.wert);
	else if (wert.typ == WertTyp.TEXT)
	{
		write("\"");
		write(*cast(dstring*) wert.wert);
		write("\"");
	}
	else
		write(wert.typ);
}

debug void schreibe_token_liste(Token[] token_liste)
{
	set_pen_trait(TextTrait.fgGrey);
	write("[");

	bool first = true;
	foreach (Token token; token_liste)
	{
		if (!first)
			write(", ");

		write("T(");
		write(token.typ);
		write(" | ");

		if (token.typ == Token_Typ.wert)
		{
			Wert wert = *cast(Wert*) token.wert;
			schreibe_schön_wert(wert);
		}
		else if (token.typ == Token_Typ.operator)
		{
			OperatorenTyp op_typ = *cast(OperatorenTyp*) token.wert;
			write(op_typ);
		}
		else if (token.typ == Token_Typ.var_typ)
		{
			WertTyp w_typ = *cast(WertTyp*) token.wert;
			write(wertTypString[w_typ]);
		}
		else if (token.typ == Token_Typ.var_name)
		{
			write(*cast(dstring*) token.wert);
		}
		else
		{
			write("INVALID");
		}

		write(")");
		first = false;
	}

	writeln("]");
	set_pen_trait(TextTrait.reset);
}

//region REPL
void print_prompt()
{
	set_pen_trait(TextTrait.fgMagenta);
	write(">>> ");
	set_pen_trait(TextTrait.reset);
}

void print_continuation()
{
	set_pen_trait(TextTrait.fgMagenta);
	write("... ");
	set_pen_trait(TextTrait.reset);
}
//endregion
