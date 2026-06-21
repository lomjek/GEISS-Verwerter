module ext.prints;

import operatoren : OperatorenTyp;

import zahl;

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
	{
		NatürlicheZahl nz = *cast(NatürlicheZahl*) wert.wert;
		write(nz.als_string);
	}
	else if (wert.typ == WertTyp.GANZE_ZAHL)
	{
		GanzeZahl gz = *cast(GanzeZahl*) wert.wert;
		write(gz.als_string);
	}
	else if (wert.typ == WertTyp.ZAHL)
	{
		Zahl z = *cast(Zahl*) wert.wert;
		write(z.als_string);
	}
	else if (wert.typ == WertTyp.TEXT)
	{
		write("\"");
		write(*cast(dstring*) wert.wert);
		write("\"");
	}
	else if (wert.typ == WertTyp.WAHRHEIT)
	{
		bool wahrheit = *cast(bool*) wert.wert;
		write(wahrheit ? "wahr" : "falsch");
	}
	else
		write(wert.typ);
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
