module repl;

import std;
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
        string repl_linie = readln().strip;

        if (repl_linie == "exit")
        {
            return;
        }

        writeln(repl_linie);

        uint fehler = interpretiere_repl_linie(repl_linie);
    }
}
