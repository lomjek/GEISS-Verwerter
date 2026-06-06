module app;

import repl;

import ext.prints;

import std.stdio : write, writeln;

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

	writeln("Hier ist leider noch nix!");
	return 1;
}
