module fehler;

import interpreter;
import operatoren;
import variablen.wert;

import std.conv : to;
import std.array : join;

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
	this(dstring variable_name, dstring[] bekannte_variablen, ulong linie = __LINE__)
	{
		dstring msg = "Variable '"d ~ variable_name ~ "' gibt es nicht!\nBekannte Variablen: "d ~
			(
				join(
					bekannte_variablen, ", ")).to!dstring;
		super(msg, linie); //Todo: Das Line getue fixen
	}
}

class Bereich_Nicht_Existent_Fehler : Fehler
{
	this(uint bereich_num, ulong linie = __LINE__)
	{
		dstring msg = "Bereich für Variablen mit der Nummer " ~ bereich_num.to!dstring ~ " existiert nicht.";
		super(msg, linie);
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
class Operation_TypenFehler : Fehler
{
	this(OperatorenTyp op_typ, WertTyp w1_typ, WertTyp w2_typ, ulong linie = __LINE__)
	{
		dstring message = "Die Operation " ~ op_typ.to!dstring ~ " kann nicht mit den Typen " ~ w1_typ.to!dstring ~ " und "
			~ w2_typ.to!dstring ~ "durchegführt werden.";
		super(message, linie);
	}
}

class Liste_TypenFehler : Fehler
{
	this(WertTyp liste_typ, WertTyp w_typ)
	{
		dstring message = "Die fixe liste voller "d
			~ liste_typ.to!dstring ~ " kann nicht "d ~ w_typ.to!dstring ~ " enthalten"d;
		super(message);
	}
}
