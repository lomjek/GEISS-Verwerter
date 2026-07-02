module variablen.speicher;

import fehler;

import zahl;

import variablen.variable;
import variablen.wert;

import ext.string;

// @ {} [] # \ || != ~

struct Bereich
{
	dstring name;
	uint uid;
	Variable[] variablen;
}

private Bereich*[] bereiche;

shared static this()
{
	bereiche ~= new Bereich("global"d, 0, [
			Variable("status_nummer"d, VariablenTyp.FIX, new Wert(WertTyp.NATÜRLICHE_ZAHL, new NatürlicheZahl())), // Exit code 

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
			// Variable gefunden.
			if (var.var_typ == VariablenTyp.FIX)
			{
				WertTyp vw_typ = (*cast(Wert*) var.wert).typ;
				WertTyp nw_typ = neuer_wert.typ;

				// Typen sind genau gleich
				if (vw_typ == nw_typ)
				{
					var.wert = neuer_wert;
				}

				// Upcasting für Zahlen  
			else if (nw_typ == WertTyp.GANZE_ZAHL && vw_typ == WertTyp.ZAHL)
				{
					GanzeZahl nw_gzahl = *cast(GanzeZahl*) neuer_wert.wert;
					Wert* nw = new Wert(WertTyp.ZAHL, new Zahl(nw_gzahl));
					var.wert = nw;
				}

				else if (nw_typ == WertTyp.NATÜRLICHE_ZAHL && vw_typ == WertTyp.ZAHL)
				{
					NatürlicheZahl nw_nzahl = *cast(NatürlicheZahl*) neuer_wert.wert;
					Wert* nw = new Wert(WertTyp.ZAHL, new Zahl(nw_nzahl));
					var.wert = nw;
				}

				else if (nw_typ == WertTyp.NATÜRLICHE_ZAHL && vw_typ == WertTyp.GANZE_ZAHL)
				{
					NatürlicheZahl nw_nzahl = *cast(NatürlicheZahl*) neuer_wert.wert;
					Wert* nw = new Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(nw_nzahl));
					var.wert = nw;
				}

				else
				{
					throw new Variable_Assign_Typ_Error(var.identifier, vw_typ, nw_typ);
				}
			}
			else if (var.var_typ == VariablenTyp.VARIABEL)
			{
				var.wert = neuer_wert;
			}
		}
	}
}
//endregion

//region Global_Helpers
int bekomme_return_status()
{
	Variable var = lies_variable(0, "status_nummer");
	Wert wert = *cast(Wert*) var.wert;
	NatürlicheZahl zahl = *cast(NatürlicheZahl*) wert.wert;

	return als_int(zahl.werte);
}
//endregion
