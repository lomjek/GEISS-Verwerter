module repl;

import std.stdio : readln, writeln, write;
import std.string : strip;
import std.conv : to;

import ext.string : dchar_from_string;

import inerpreter;

// @ {} [] # \ || != ~

void print_prompt()
{
    write("\033[35m>>> \033[0m");
}

void main(string[] args)
{
    writeln("Hello World");
    while (true)
    {
        print_prompt();
        dchar[] repl_linie = [];
        readln(repl_linie);
        repl_linie = repl_linie.strip;

        if (repl_linie == "exit".dchar_from_string)
        {
            return;
        }
        else if (repl_linie == "clear".dchar_from_string)
        {
            write("\x1b[2J\x1b[H");
            continue;
        }
        else if (repl_linie == null || repl_linie.length == 0)
        {
            continue;
        }

        writeln(repl_linie);

        dstring repl_dstring = repl_linie.to!dstring;

        uint fehler = interpretiere_repl_linie(repl_dstring);
    }
}
