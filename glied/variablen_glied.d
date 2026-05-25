module glied.variablen_glied;

import variablen.wert;
import variablen.speicher;
import variablen.variable;

import glied.glied;

import std.stdio : write;

class Erstelle_Variable_Glied : Glied
{
	private WertTyp wert_typ;
	private VariablenTyp var_typ;
	public dstring var_name;

	override public Wert verwerte(uint bereich)
	{
		Wert* wert = new Wert(wert_typ, null);
		erstelle_variable(bereich, var_name, var_typ, wert);
		return Wert(WertTyp.INVALID, null);
	}

	override public void schreibe_baum()
	{
		write("[ERSTELLE_VARIABLE]{" ~ var_name ~ "}");
	}

	override public bool ist_vollständig()
	{
		return true;
	}

	this(dstring var_name, WertTyp constructor)
	{
		this.var_name = var_name;
		if (constructor == WertTyp.INVALID)
		{
			this.var_typ = VariablenTyp.VARIABEL;
		}
		else
		{
			this.var_typ = VariablenTyp.FIX;
		}
		wert_typ = constructor;
	}
}

class Setze_Variable_Glied : Glied
{
	dstring var_name;
	Glied assign_wert;

	override public Wert verwerte(uint bereich)
	{
		Wert result = assign_wert.verwerte(bereich);
		Wert* pointer = new Wert(result.typ, result.wert);
		setze_variable(bereich, var_name, pointer);
		return Wert(WertTyp.INVALID, null);
	}

	override public void schreibe_baum()
	{
		write("[SETZE_VARIABLE " ~ var_name ~ "]{");
		assign_wert.schreibe_baum;
		write("}");
	}

	override public bool ist_vollständig()
	{
		return (var_name != "" && assign_wert !is null);
	}
}

class Lese_Variable_Glied : Glied
{
	dstring var_name;

	override public Wert verwerte(uint bereich)
	{
		Variable var = lies_variable(bereich, var_name);

		if (var.var_typ == VariablenTyp.INVALID || var.wert is null)
			throw new Exception("Die Variable hat keinen Wert");

		Wert wert = *cast(Wert*) var.wert;
		return wert;
	}

	override public void schreibe_baum()
	{
		write("{" ~ var_name ~ "}");
	}

	override public bool ist_vollständig()
	{
		return var_name != "";
	}

	this(dstring namen)
	{
		this.var_name = namen;
	}
}
