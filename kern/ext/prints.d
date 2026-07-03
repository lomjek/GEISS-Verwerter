module ext.prints;

import operatoren : OperatorenTyp;

import liste;
import zahl;
import std.conv : to;

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

void set_pen_trait(TextTrait tt = TextTrait.reset)
{
	write(cast(string) tt);
}

void schreibe_schön_wert(Wert wert)
{
	write(wert.als_schön_string);
}

string als_schön_string(Wert wert)
{
	string str;

	switch (wert.typ)
	{
	case WertTyp.NATÜRLICHE_ZAHL:
		NatürlicheZahl nz = *cast(NatürlicheZahl*) wert.wert;
		str = nz.als_string;
		break;

	case WertTyp.GANZE_ZAHL:
		GanzeZahl gz = *cast(GanzeZahl*) wert.wert;
		str = gz.als_string;
		break;

	case WertTyp.ZAHL:
		Zahl z = *cast(Zahl*) wert.wert;
		str = z.als_string;
		break;

	case WertTyp.TEXT:
		str = "\"";
		str ~= (*cast(dstring*) wert.wert).to!string;
		str ~= "\"";
		break;

	case WertTyp.WAHRHEIT:
		bool wahrheit = *cast(bool*) wert.wert;
		str = wahrheit ? "wahr" : "falsch";
		break;

	case WertTyp.LISTE:
		Liste li = *cast(Liste*) wert.wert;
		str = li.als_string;
		break;

	default:
		str = wert.typ.to!string;
	}

	return str;
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
