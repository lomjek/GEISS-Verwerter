module glied.funktion_glied;

import glied.glied;
import glied.variablen_glied : Erstelle_Variable_Glied;

import variablen.wert;
import variablen.speicher;
import variablen.variable;

import ext.prints;

import fehler;
import zahl;
import text;

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
			throw new Fehler("Variable " ~ var.to!string ~ " ist keine Funktion!");
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
			Wert* argument = new Wert(argumente[i].verwerte(bereich));
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
	Erstelle_Variable_Glied[] return_values;

	this(Erstelle_Variable_Glied[] parameter, Erstelle_Variable_Glied[] return_values)
	{
		this.parameter = parameter;
		this.return_values = return_values;
	}
}

//MARK: Native func
enum MethodenTyp
{
	PRINT,
	ALS_TEXT,
	ALS_ZAHL,
}

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

		case MethodenTyp.ALS_TEXT:
			Wert zahl = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
			Zahl z;
			if (zahl.typ == WertTyp.ZAHL)
				z = *cast(Zahl*) zahl.wert;
			else if (zahl.typ == WertTyp.GANZE_ZAHL)
				z = Zahl(*cast(GanzeZahl*) zahl.wert);
			else if (zahl.typ == WertTyp.NATÜRLICHE_ZAHL)
				z = Zahl(*cast(NatürlicheZahl*) zahl.wert);
			else
				throw new Fehler("Funktion als_text benötigt eine Zahl als Eingabe");

			string str = z.als_string;

			return Wert(WertTyp.TEXT, new Text(str));

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

	override string toString() const
	{
		return "G(" ~ typ.to!string ~ ")";
	}

	this(MethodenTyp funktion)
	{
		this.typ = funktion;

		Erstelle_Variable_Glied[] parameter;
		Erstelle_Variable_Glied[] return_values;

		if (typ == MethodenTyp.PRINT)
		{
			Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.TEXT);
			parameter ~= evg;
		}
		else if (typ == MethodenTyp.ALS_TEXT)
		{
			// Parameter
			Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.ZAHL);
			parameter ~= evg;

			// Return Value
			Erstelle_Variable_Glied rvg = new Erstelle_Variable_Glied("ausgabe", WertTyp.TEXT);
			return_values ~= rvg;
		}

		super(parameter, return_values);
	}
}
