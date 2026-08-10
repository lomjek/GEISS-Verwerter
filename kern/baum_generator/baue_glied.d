module baum_generator.baue_glied;

import ext.klasse;
import glied;
import fehler;

import std.algorithm : remove;
import std.stdio : write, writeln;

Glied[] baue_glied(Glied[] glieder_liste, ulong glied_index)
{
	Glied glied = glieder_liste[glied_index];

	if (glied.instanceof!OperationGlied)
		return baue_glied_OperationenGlied(cast(OperationGlied) glied, glieder_liste, glied_index);

	else if (glied.instanceof!Setze_Variable_Glied)
		return baue_glied_SetzeVarGlied(cast(Setze_Variable_Glied) glied, glieder_liste, glied_index);

	else if (glied.instanceof!Falls_BlockGlied)
		return baue_glied_Falls_Glied(cast(Falls_BlockGlied) glied, glieder_liste, glied_index);

	else if (glied.instanceof!Sonst_BlockGlied)
		return baue_glied_Sonst_Glied(cast(Sonst_BlockGlied) glied, glieder_liste, glied_index);

	else if (glied.instanceof!Solange_BlockGlied)
		return baue_Solange_Glied(cast(Solange_BlockGlied) glied, glieder_liste, glied_index);

	writeln("WARNUNG: Nichts wurde geparst.");
	return glieder_liste;
}

Glied[] baue_glied_OperationenGlied(OperationGlied op_glied, Glied[] glieder_liste, ulong glied_index)
{
	if (glied_index <= 0 || glied_index >= glieder_liste.length)
		throw new Parse_Fehler("Eine Operation kann nicht das erste oder letzte Glied sein.");

	if (op_glied.ist_vollständig)
		throw new Parse_Fehler("Das hier wurde schon geparst, kann nicht noch einmal");

	Glied wert1 = glieder_liste[glied_index - 1];
	Glied wert2 = glieder_liste[glied_index + 1];

	op_glied.werte[0] = wert1;
	op_glied.werte[1] = wert2;

	glieder_liste = glieder_liste.remove(glied_index + 1);
	glieder_liste = glieder_liste.remove(glied_index - 1);

	return glieder_liste;
}

Glied[] baue_glied_SetzeVarGlied(Setze_Variable_Glied svg, Glied[] glieder_liste, ulong glied_index)
{
	if (glied_index < 1)
		throw new Position_Fehler(svg, glied_index);

	if (glied_index >= glieder_liste.length)
		throw new Position_Fehler(svg, glied_index);

	Glied vorher_glied = glieder_liste[glied_index - 1];
	Glied naher_glied = glieder_liste[glied_index + 1];

	if (vorher_glied.instanceof!Erstelle_Variable_Glied)
	{
		Erstelle_Variable_Glied evg = cast(Erstelle_Variable_Glied) vorher_glied;
		svg.var_name = evg.var_name;
		svg.assign_wert = naher_glied;
		glieder_liste = glieder_liste.remove(glied_index + 1);
	}
	else if (vorher_glied.instanceof!Lese_Variable_Glied)
	{
		Lese_Variable_Glied lvg = cast(Lese_Variable_Glied) vorher_glied;
		svg.var_name = lvg.var_name;
		svg.assign_wert = naher_glied;

		glieder_liste = glieder_liste.remove(glied_index + 1);
		glieder_liste = glieder_liste.remove(glied_index - 1);
	}
	else
	{
		writeln(vorher_glied);
		throw new Parse_Fehler("Variablennamen unbekannt!");
	}

	return glieder_liste;
}

Glied[] baue_glied_Falls_Glied(Falls_BlockGlied glied, Glied[] glieder_liste, ulong glied_index)
{
	if ((glied_index + 2) >= glieder_liste.length)
	{
		writeln(glied_index, glieder_liste);
		throw new Parse_Fehler(
			"Das Wort Falls ist zu nahe am Ende...");
	}

	if (glieder_liste[glied_index + 2].instanceof!BlockGlied)
		glied.aktionen = (cast(BlockGlied) glieder_liste[glied_index + 2]).aktionen;
	else
		glied.aktionen ~= glieder_liste[glied_index + 2];

	glied.bedingung = glieder_liste[glied_index + 1];

	glieder_liste = glieder_liste.remove(glied_index + 2);
	glieder_liste = glieder_liste.remove(glied_index + 1);

	if (glieder_liste[glied_index + 1].instanceof!Sonst_BlockGlied)
	{
		Sonst_BlockGlied sbgl = cast(Sonst_BlockGlied) glieder_liste[glied_index + 1];

		Falls_Sonst_BlockGlied fsbgl = new Falls_Sonst_BlockGlied(glied, sbgl);

		glieder_liste[glied_index] = fsbgl;
		glieder_liste = glieder_liste.remove(glied_index + 1);
	}

	return glieder_liste;
}

Glied[] baue_glied_Sonst_Glied(Sonst_BlockGlied glied, Glied[] glieder_liste, ulong glied_index)
{
	if ((glied_index + 1) >= glieder_liste.length)
	{
		throw new Parse_Fehler(
			"Das Wort Sonst ist zu nahe am Ende...");
	}

	if (glieder_liste[glied_index + 1].is_class!BlockGlied)
		glied.aktionen = (cast(BlockGlied) glieder_liste[glied_index + 1]).aktionen;
	else
		glied.aktionen ~= glieder_liste[glied_index + 1];

	glieder_liste = glieder_liste.remove(glied_index + 1);
	return glieder_liste;
}

Glied[] baue_Solange_Glied(Solange_BlockGlied glied, Glied[] glieder_liste, ulong glied_index)
{
	if ((glied_index + 2) >= glieder_liste.length)
		throw new Parse_Fehler("Das Wort SOLANGE ist zu nahe am Ende...");

	if (glieder_liste[glied_index + 2].is_class!BlockGlied)
		glied.aktionen = (cast(BlockGlied) glieder_liste[glied_index + 2]).aktionen;
	else
		glied.aktionen ~= glieder_liste[glied_index + 2];

	glied.bedingung = glieder_liste[glied_index + 1];

	glieder_liste = glieder_liste.remove(glied_index + 2);
	glieder_liste = glieder_liste.remove(glied_index + 1);

	return glieder_liste;
}
