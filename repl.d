module repl;

import std.stdio : readln, writeln, write;
import std.string : strip;

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
        repl_linie.strip;

        if (repl_linie == "exit")
        {
            return;
        }
        else if (repl_linie == "clear")
        {
            write("\x1b[2J\x1b[H");
            continue;
        }

        writeln(repl_linie);

        uint fehler = interpretiere_repl_linie(repl_linie);
    }
}
