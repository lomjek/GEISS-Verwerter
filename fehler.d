module fehler;

import app;

import std.conv : to;

class Fehler : Exception
{
	this(dstring msg, size_t line = __LINE__)
	{
		if (repl_mode)
		{
			super(msg.to!string, "", 1, null);
		}
		else
		{
			super(msg.to!string, file_name.to!string, line, null);
		}
	}
}

abstract class VariablenFehler : Fehler
{
	this(dstring msg, size_t line = __LINE__)
	{
		super(msg, line);
	}
}

class Variable_Nicht_Existent_Fehler : VariablenFehler
{
	this(dstring variable_name)
	{
		dstring msg = "Variable '" ~ variable_name ~ "' gibt es nicht!";
		super(msg); //Todo: Das Line getue fixen
	}
}

class Variable_Schon_Existent_Fehler : VariablenFehler
{
	this(dstring variable_name)
	{
		dstring msg = "Variable '" ~ variable_name ~ "' gibt es schon!";
		super(msg);
	}
}
