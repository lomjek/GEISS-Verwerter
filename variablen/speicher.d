module variablen.speicher;

import fehler;

import variablen.variable;
import variablen.wert;

import ext.string;

struct Bereich
{
	dstring name;
	uint uid;
	Variable[] variablen;
}

private Bereich*[] bereiche;

static this()
{
	bereiche ~= new Bereich("global"d, 0, [
			//Hier müssten so Sachen sein wie name der Datei, eine exit Funktion, usw, usw...
		]);
}

uint initialisiere_bereich(dstring name)
{
	uint bereich_level = 1;
	while (bereiche[bereich_level] != null)
	{
		bereich_level++;
	}
	bereiche[bereich_level] = new Bereich(name, bereich_level, []);
	return bereich_level;
}

bool variable_existiert(uint bereich_num, dstring var_name)
{
	if (bereiche[bereich_num] == null)
		return false;

	foreach (Variable var; bereiche[bereich_num].variablen)
	{
		if (var_name == var.identifier)
		{
			return true;
		}
	}
	return false;
}

//region API
Variable lies_variable(uint bereich_num, dstring var_name)
{
	if (bereiche[bereich_num] == null)
		throw new Variable_Nicht_Existent_Fehler(var_name);

	Bereich bereich = *bereiche[bereich_num];

	foreach (Variable var; bereich.variablen)
	{
		if (var.identifier == var_name)
		{
			return var;
		}
	}
	throw new Variable_Nicht_Existent_Fehler(var_name);
}

void erstelle_variable(uint bereich_num, dstring var_name, VariablenTyp var_typ, Wert* init_wert)
{
	if (bereiche[bereich_num] == null)
		throw new Error("Der Bereich für die Variable existiert nicht!");

	if (variable_existiert(bereich_num, var_name))
	{
		throw new Variable_Schon_Existent_Fehler(var_name);
	}

	bereiche[bereich_num].variablen ~= Variable(var_name, var_typ, init_wert);
}

void setze_variable(uint bereich_num, dstring var_name, Wert* neuer_wert)
{
	if (bereiche[bereich_num] == null)
		throw new Error("Der Bereich für die Variable existiert nicht!");

	if (!variable_existiert(bereich_num, var_name))
		throw new Variable_Nicht_Existent_Fehler(var_name);

	Bereich* bereich = bereiche[bereich_num];

	foreach (ref Variable var; bereich.variablen)
	{
		if (var.identifier == var_name)
		{
			//TODO: Hier muss man noch checken, ob die Variable dynamisch ist, ob der Wert richtig ist, etc, etc...
			var.wert = neuer_wert;
		}
	}
}
//endregion
