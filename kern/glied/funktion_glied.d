module glied.funktion_glied;

import glied.glied;
import glied.block_glied;
import glied.variablen_glied;

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
	Glied[] argumente;
	dstring identifier;

	override public void schreibe_baum()
	{
		write("[FUNKTION]{");
		write(identifier);
		write(", ");
		argumente.to!string;
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

		dstring[] namen;

		foreach (Erstelle_Variable_Glied evg; fg.parameter)
		{
			evg.verwerte(neuer_bereich);
			namen ~= evg.var_name;
		}

		if (argumente.length != namen.length)
		{
			throw new Fehler("Die Anzahl Argumenten ist nicht richtg.");
		}

		for (ulong i = 0; i < argumente.length; i++)
		{
			Wert* argument = new Wert(argumente[i].verwerte(neuer_bereich));
			setze_variable(neuer_bereich, namen[i], argument);
		}

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
		return "G(" ~ identifier.to!string ~ " | " ~ argumente.length.to!string ~ ")";
	}

	this(dstring funk_name, Glied[] argumente)
	{
		identifier = funk_name;
		this.argumente = argumente;
	}
}

class Funktion_Glied : Glied
{
	Erstelle_Variable_Glied[] parameter;

	this(Erstelle_Variable_Glied[] parameter)
	{
		this.parameter = parameter;
	}
}

//MARK: Native func
enum MethodenTyp
{
	PRINT,
	ALS_TEXT,
}

// Muss ein BlockGlied sein, damit es in eine Funktion_Glied funktion reinpasst.
class EingebauteFunktion_Glied : Funktion_Glied
{
	MethodenTyp typ;

	override public Wert verwerte(uint bereich)
	{
		switch (typ)
		{
		case MethodenTyp.PRINT:
			Wert text = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
			schreibe_schön_wert(text);
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

		Erstelle_Variable_Glied[] parameter;

		if (typ == MethodenTyp.PRINT)
		{
			Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.TEXT);
			parameter ~= evg;
		}

		super(parameter);
	}
}
