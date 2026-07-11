module glied.funktion_glied;

import glied.glied;
import glied.block_glied;

import variablen.wert;
import variablen.speicher;
import variablen.variable;

import ext.prints;

import fehler;

import std.stdio : writeln, write;
import std.conv : to;

// @ {} [] # \ || != ~

class Funktion_Abrufen_Glied : Glied
{
	Glied[] argument;
	dstring identifier;

	override public void schreibe_baum()
	{
		write("[FUNKTION]{");
		write(identifier);
		write(", ");
		argument.to!string;
		write("}");
	}

	override public Wert verwerte(uint bereich)
	{
		uint neuer_bereich = initialisiere_bereich(identifier);
		Variable var = lies_variable(bereich, identifier);

		if (var.var_typ != VariablenTyp.FUNKTION)
		{
			throw new Fehler("Variable "d ~ var.to!dstring ~ " ist keine Funktion!"d);
		}

		Funktion_Glied fg = cast(Funktion_Glied) var.wert;
		fg.parameter = argument[0]; //TODO: Fix this bandaid

		Wert resultat = fg.verwerte(neuer_bereich);
		lösche_bereich(neuer_bereich);
		return resultat;
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	override string toString() const @safe pure
	{
		return "G(" ~ identifier.to!string ~ " | " ~ argument.length.to!string ~ ")";
	}

	this(dstring funk_name, Glied[] argument)
	{
		identifier = funk_name;
		this.argument = argument;
	}
}

class Funktion_Glied : Glied
{
	Glied parameter;

}

//MARK: Native func
enum MethodenTyp
{
	PRINT
}

// Muss ein BlockGlied sein, damit es in eine Funktion_Glied funktion reinpasst.
class EingebauteFunktion_Glied : Funktion_Glied
{
	MethodenTyp typ;

	override public Wert verwerte(uint bereich)
	{
		Wert argumente = parameter.verwerte(bereich);

		switch (typ)
		{
		case MethodenTyp.PRINT:
			schreibe_schön_wert(argumente);
			writeln;
			goto default;

			// Vielleicht müssen einige Methoden Sachen zurückgeben

		default:
			return Wert(WertTyp.INVALID, null);
		}

	}

	override public bool ist_vollständig()
	{
		return parameter !is null;
	}

	override public void schreibe_baum()
	{
		write(typ.to!string);
	}

	this(MethodenTyp funktion)
	{
		this.typ = typ;
	}
}
