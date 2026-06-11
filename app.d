module app;

import repl;
import interpreter;

import ext.prints;
import ext.datei;

import std.stdio : write, writeln;
import std.conv : to;

bool repl_mode = false;
dstring file_name = "";

int main(string[] args)
{
	if (args.length == 1)
	{
		repl_mode = true;

		set_pen_trait(TextTrait.fgGreen);
		writeln("Willkommen bei MÖWE! Version: <-1>");
		set_pen_trait(TextTrait.reset);

		enter_repl_loop();
		return 0;
	}

	if (args.length == 2)
	{
		dstring file = args[1].to!dstring;
		dstring datei_inhalt = datei_lesen(file);
		interpretiere(datei_inhalt);
		return 0;
	}

	writeln("Entweder ohne Argumente für REPL, oder aber mit einer Datei, als argument....");
	return 1;
}
