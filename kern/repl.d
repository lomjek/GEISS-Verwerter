module repl;

import std.stdio : readln, writeln, write;
import std.conv : to;

import ext.string : dchar_from_string, strip;
import ext.prints;

import glied.signal_glied : Beende_Programm_Signal;

debug
{
	import variablen.speicher : dump_speicher;
}

import fehler;

import interpreter;

// @ {} [] # \ || != ~

void enter_repl_loop()
{
	while (true)
	{
		try
		{
			print_prompt();

			dchar[] repl_linie = [];
			readln(repl_linie);

			repl_linie = repl_linie.strip;

			if (repl_linie == "clear".dchar_from_string)
			{
				write("\x1b[2J\x1b[H");
				continue;
			}
			else if (repl_linie == "memdump".dchar_from_string)
			{
				debug
				{
					dump_speicher;
					continue;
				}
			}
			else if (repl_linie == "hilfe".dchar_from_string)
			{
				schreibe_hilfe();
				continue;
			}
			else if (repl_linie == null || repl_linie.length == 0)
			{
				continue;
			}

			dstring repl_dstring = repl_linie.to!dstring;

			interpretiere(repl_dstring);
		}
		catch (Fehler fehler)
		{
			set_pen_trait(TextTrait.fgRed);
			writeln(fehler.msg);
			set_pen_trait(TextTrait.reset);
		}
    catch (Beende_Programm_Signal){
      break;
    }
	}
}
