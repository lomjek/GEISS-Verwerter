module ext.prints;

import operatoren : OperatorenTyp;

import liste;
import zahl;
import text;

import variablen.wert;

import std.stdio : write, writeln;
import std.conv : to;

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
		Nzahl nz = *cast(Nzahl*) wert.wert;
		str = nz.als_string;
		break;

	case WertTyp.GANZE_ZAHL:
		Gzahl gz = *cast(Gzahl*) wert.wert;
		str = gz.als_string;
		break;

	case WertTyp.ZAHL:
		Zahl z = *cast(Zahl*) wert.wert;
		str = z.als_string;
		break;

	case WertTyp.TEXT:
		str = "\"";
		Text text = *cast(Text*) wert.wert;
		str ~= text.str;
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

void schreibe_hilfe()
{
	set_pen_trait(TextTrait.fgGreen);
	writeln("Schön dich hier zu sehen. Vor dir hast du GEISS, meine kleine Programmiersprache");
	set_pen_trait();
	writeln("Falls du dieses Program zum ersten Mal benutzt, wäre es gescheit ein keines Bis-");
	writeln("chen meiner Dokumentation zu lesen, wenn du aber zu faul bist, dann hier einige");
	writeln("nützliche Informationen:");
	writeln;
	writeln("varbiable x // Damit erstellst du eine Variable.");
	writeln("x <- 'Hallo Welt' // So kannst du einen Wert in die Variable schreiben");
	writeln("schreibe x // So kannst du deinen Text in die Ausgabe schreiben.");
	writeln;
	writeln("Um dies Programm zu verlassen, schreibe 'beende programm' in die Eingabe,");
	writeln("oder drücke ctrl+C auf deiner Tastatur.");
	writeln;
	writeln("Viel Spass");
}
//endregion
