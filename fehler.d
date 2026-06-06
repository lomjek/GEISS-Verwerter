module fehler;

import app;
import operatoren;
import variablen.wert;

import std.conv : to;

// @ {} [] # \ || != ~

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

//MARK: Variablen
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

class Variable_Assign_Typ_Error : VariablenFehler
{
	this(dstring variable_name, WertTyp variable_typ, WertTyp wert_typ)
	{
		dstring msg = "Variable '" ~ variable_name ~ "' mit dem Typ " ~ variable_typ.to!dstring ~
			" kann nicht Wert von Typ " ~ wert_typ.to!dstring ~ " enthalten";
		super(msg);
	}
}

//MARK: Typenfehler
abstract class TypenFehler : Fehler
{
	this(dstring msg, size_t linie = __LINE__)
	{
		super(msg, linie);
	}
}

class Operation_TypenFehler : TypenFehler
{
	this(OperatorenTyp op_typ, WertTyp w1_typ, WertTyp w2_typ)
	{
		dstring message = "Die Operation " ~ op_typ.to!dstring ~ " kann nicht mit den Typen " ~ w1_typ.to!dstring ~ " und "
			~ w2_typ.to!dstring ~ "durchegführt werden.";
		super(message);
	}
}
