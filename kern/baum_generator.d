module baum_generator;

import operatoren;
import schlüsselwörter;

import ext.prints;
import ext.klasse;

import liste;

import fehler;

import glied;

import variablen.wert;

import std.algorithm : remove, canFind;
import std.stdio : writeln, write;
import std.conv : to;

// @ {} [] # \ || != ~

enum Aktion_Gewicht
{
	INVALID,

	FUNKTION_ABRUFEN,

	SETZE_VARIABLE,

	SOLANGE,

	FALLS_SONST,

	GLEICH,

	GRÖSSER_ALS,
	GRÖSSER_GLEICH,

	KLEINER_ALS,
	KLEINER_GLEICH,

	PLUS_MINUS,
	MAL_DURCH,
	HOCH,

}

Aktion_Gewicht[OperatorenTyp] operatoren_Gewicht = [
	OperatorenTyp.PLUS: Aktion_Gewicht.PLUS_MINUS,
	OperatorenTyp.MINUS: Aktion_Gewicht.PLUS_MINUS,

	OperatorenTyp.MAL: Aktion_Gewicht.MAL_DURCH,
	OperatorenTyp.GETEILT: Aktion_Gewicht.MAL_DURCH,

	OperatorenTyp.HOCH: Aktion_Gewicht.HOCH,

	OperatorenTyp.GLEICH: Aktion_Gewicht.GLEICH,

	OperatorenTyp.GRÖSSER_ALS: Aktion_Gewicht.GRÖSSER_ALS,
	//TODO: GRÖSSER GLEICH

	OperatorenTyp.KLEINER_ALS: Aktion_Gewicht.KLEINER_ALS,
	//TODO: KLEINER_GLEICH
];

nothrow @safe @nogc
private uint get_op_prio_length()
{
	return Aktion_Gewicht.max - Aktion_Gewicht.min + 1;
}

private bool ist_fertig(Glied[] glieder_liste)
{
	foreach (Glied glied; glieder_liste)
	{
		if (glied.ist_vollständig == false)
		{
			return false;
		}
	}
	return true;
}

//MARK: master_baum
Programm_BlockGlied generiere_master_baum(Glied[] glieder_liste)
{
	//region Sind alle Klammern geschlossen?
	uint offene_klammern = 0;
	uint offene_eckige_klammern = 0;
	uint offene_geschwungene_klammern = 0;

	foreach (Glied glied; glieder_liste)
	{
		if (!glied.instanceof!OperationGlied)
		{
			continue;
		}

		OperatorenTyp op_typ = (cast(OperationGlied) glied).operationenTyp;
		if (op_typ == OperatorenTyp.KLAMMER_AUF)
			offene_klammern++;
		else if (op_typ == OperatorenTyp.ECKIGE_KLAMMER_AUF)
			offene_eckige_klammern++;
		else if (op_typ == OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF)
			offene_geschwungene_klammern++;

		else if (op_typ == OperatorenTyp.KLAMMER_ZU)
			offene_klammern--;
		else if (op_typ == OperatorenTyp.ECKIGE_KLAMMER_ZU)
			offene_eckige_klammern--;
		else if (op_typ == OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU)
			offene_geschwungene_klammern--;
	}

	if (offene_klammern != 0)
	{
		throw new Fehler("FEHLER: Nicht alle Klammern sind zu!"d);
	}
	if (offene_eckige_klammern != 0)
	{
		throw new Fehler("FEHLER: Nicht alle eckigen Klammern sind zu!"d);
	}
	if (offene_geschwungene_klammern != 0)
	{
		throw new Fehler("FEHLER: Nicht alle geschwungenen Klammern sind zu!"d);
	}
	//endregion

	ulong length = glieder_liste.length;
	for (ulong i = 0; i < length; i++)
	{
		Glied glied = glieder_liste[i];

		// RÜCK-PFEIL wird umgewandelt zu Setze_VAR_Glied
		if (glied.instanceof!OperationGlied)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;
			if (op_glied.operationenTyp == OperatorenTyp.RÜCK_PFEIL)
			{
				glieder_liste[i] = new Setze_Variable_Glied();
			}

		}
		// WT_GLIED wird zu VAR_bauen node umgewandelt.
		else if (glied.instanceof!WT_Glied && i + 1 < length &&
			glieder_liste[i + 1].instanceof!Lese_Variable_Glied)
		{
			dstring var_name = (cast(Lese_Variable_Glied) glieder_liste[i + 1]).var_name;
			WertTyp wert_typ = (cast(WT_Glied) glied).vt;
			glieder_liste[i] = new Erstelle_Variable_Glied(var_name, wert_typ);
			glieder_liste = glieder_liste.remove(i + 1);
			length--;
		}
	}

	glieder_liste = listen_zusammenfassen(glieder_liste);

	Programm_BlockGlied bgl = new Programm_BlockGlied();

	bgl.aktionen = generiere_baum(glieder_liste);

	debug
	{
		write("BAUM: ");
		set_pen_trait(TextTrait.fgCyan);
		bgl.schreibe_baum;
		set_pen_trait(TextTrait.reset);
		write("\n");
	}

	return bgl;
}

//MARK: generiere_baum
Glied[] generiere_baum(Glied[] glieder_liste)
{
	Glied[][] matrix;
	ulong depth = 0;

	foreach (Glied glied; glieder_liste)
	{
		if (glied.instanceof!OperationGlied) // Könnte Klammer sein -> Subblock
		{
			OperatorenTyp op_typ = (cast(OperationGlied) glied).operationenTyp;

			if (KLAMMERN_AUF.canFind(op_typ))
			{
				depth++;
				continue;
			}
			else if (KLAMMERN_ZU.canFind(op_typ))
			{
				if (op_typ == OperatorenTyp.KLAMMER_ZU)
				{
					//TODO: if previous glied is lies_variable parse for argumente

					Glied[] geparste_teil = generiere_linie(matrix[depth]);
					// Der geparste Teil sollte theoretisch nur ein lang sein...
					matrix[depth - 1] ~= geparste_teil;
				}
				else if (op_typ == OperatorenTyp.ECKIGE_KLAMMER_ZU)
				{
					//TODO: KLAMMER ZU Liste Handling
					depth--;
					continue;
				}
				else if (op_typ == OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU)
				{
					Glied[] geparste_teil = generiere_linie(matrix[depth]);
					matrix[depth - 1] ~= new BlockGlied(geparste_teil);

				}

				matrix[depth] = []; // Leere das jetzt nicht mehr benötigte array.

				depth--;
				continue;
			}
			// Ev. brauche ich noch Spitze Klammer zu für nacher. 
		}

		while (matrix.length <= depth)
		{
			matrix.length = depth + 1;
		}

		matrix[depth] ~= glied;
	}

	debug
	{
		write("Matrix: ");
		set_pen_trait(TextTrait.fgGrey);
		writeln(matrix);
		set_pen_trait();
	}

	return generiere_linie(matrix[0]);
}

//MARK: generiere_linie
debug ulong encounters = 0;

Glied[] generiere_linie(Glied[] glieder_liste)
{
	uint _Op_wiederholungen = 0;
	MPO wiederholtes_MPO = MPO();
	// Diese Variable ist dazu da, dass wenn der Parser keine Aktion findet,
	// aber der Baum noch nich abgeschlossen ist, er sich nicht in einer
	// endlosen Schleife verhaddert. 

	while (!glieder_liste.ist_fertig) // Muss vermutlich geändert werden.
	{
		debug
		{
			write("GL (2.");
			write(encounters);
			write("): ");
			set_pen_trait(TextTrait.fgGrey);
			writeln(glieder_liste);
			set_pen_trait(TextTrait.reset);
			encounters++;
		}

		MPO mpo = finde_MPO(glieder_liste);
		ulong max_priority_index = mpo.index;

		if (mpo == wiederholtes_MPO)
			_Op_wiederholungen++;
		else
			_Op_wiederholungen = 0; // Wenn man keine Operation findet, macht man diese Zahl grösser.
		// Bei genug Wiederhloungen beendet man die Schleife mit einem Fehler.
		// Es sollte eigentlich nie passieren, aber jetzt in der BETA-Phase,
		// hilft mir das Extrem beim Debuggen. // TODO: Braucht es das am Schluss?
		if (_Op_wiederholungen >= 10)
		{
			throw new Fehler(
				"Schon zehn Mal hintereinander ist nichts gescheites geparst worden. Es sollte nie hierhin kommen."d);
		}
		wiederholtes_MPO = mpo;

		debug
		{
			set_pen_trait(TextTrait.fgGrey);
			write(mpo);
			write(" in List ");
			writeln(glieder_liste);
			set_pen_trait(TextTrait.reset);
		}

		glieder_liste = baue_glied(glieder_liste, max_priority_index);

		//Zusammenziehen von Falls_Sonst Blocks
		//TODO: Migration nach konstruktor von FALLS Blöcken.
		for (ulong i = 0; (i + 1) < glieder_liste.length; i++)
		{

		}
	}

	return glieder_liste;
}

//MARK: ListenParsing

/// Nimmt eine Liste ohne eckigen Klammern und gibt daraus
/// ein ListeWert_Glied mit der gegebenen Liste. Alle 
/// Kommas werden einfach rausfiltriert.
ListeWert_Glied liste_erstellen(Glied[] glieder_liste)
{
	Glied[] werte;

	foreach (Glied glied; glieder_liste)
	{
		if (glied.instanceof!OperationGlied)
		{
			if ((cast(OperationGlied) glied).operationenTyp == OperatorenTyp.KOMMA)
			{
				continue;
			}
		}

		werte ~= glied;
	}

	return new ListeWert_Glied(werte);
}

Glied[] listen_zusammenfassen(Glied[] glieder_liste)
{
	ulong eckige_klammern_offen = 0;
	Glied[][] neue_gl;

	ulong arr_length = glieder_liste.length;

	for (ulong i = 0; i < arr_length; i++)
	{
		Glied glied = glieder_liste[i];

		if (glied.instanceof!OperationGlied)
		{
			if ((cast(OperationGlied) glied).operationenTyp == OperatorenTyp.ECKIGE_KLAMMER_AUF)
			{
				eckige_klammern_offen++;
				continue;
			}
			else if ((cast(OperationGlied) glied)
				.operationenTyp == OperatorenTyp.ECKIGE_KLAMMER_ZU)
			{
				if (eckige_klammern_offen == 0)
					throw new Fehler("Es werden mehr Klammern zu als aufgemacht.");

				eckige_klammern_offen--;
				neue_gl[eckige_klammern_offen] ~= liste_erstellen(
					neue_gl[eckige_klammern_offen + 1]);
				neue_gl[eckige_klammern_offen + 1] = [];
				continue;
			}
		}

		if (neue_gl.length != (1 + eckige_klammern_offen))
		{
			neue_gl.length = eckige_klammern_offen + 1;
		}

		neue_gl[eckige_klammern_offen] ~= glieder_liste[i];
	}

	return neue_gl[0];
}

//MARK: finde_mpo

/// Max Priority Operation
/// Hält den Wert und den index zum Glied, welches am dringendsten gebaut werden muss.
struct MPO
{
	ulong value = 0;
	ulong index = 0;

	string toString() const @safe pure nothrow
	{
		return "MPO(" ~ value.to!string ~ " at index " ~ index.to!string ~ ")";
	}
}

void passe_mpo_an(MPO* mpo, Aktion_Gewicht op, ulong index)
{
	if (mpo.value < op)
	{
		mpo.value = op;
		mpo.index = index;
	}
}

MPO finde_MPO(Glied[] glieder_liste)
{
	MPO current_mpo = MPO();

	if (glieder_liste.length == 0)
		return current_mpo;

	for (ulong i = glieder_liste.length; i > 0; i--)
	{
		Glied glied = glieder_liste[i - 1];

		if (glied.ist_vollständig)
			continue;

		if (glied.instanceof!OperationGlied)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;
			if (op_glied.operationenTyp in operatoren_Gewicht)
				(&current_mpo).passe_mpo_an(operatoren_Gewicht[op_glied.operationenTyp], i);
			else
				throw new Fehler("Dieser Operator hat keine Option. Das nicht gut."); // TODO: Sollte nie hier sein.
		}
		else if (glied.instanceof!Setze_Variable_Glied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.SETZE_VARIABLE, i);
		else if (glied.instanceof!Falls_BlockGlied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);
		else if (glied.instanceof!Sonst_BlockGlied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);

	}

	if (current_mpo.index == 0)
		throw new Fehler("Kein MPO gefunden");

	current_mpo.index -= 1;

	return current_mpo;
}

//MARK: baue_glied
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
		throw new Fehler("Eine Operation kann nicht das erste oder letzte Glied sein.");

	if (op_glied.ist_vollständig)
		throw new Fehler("Das hier wurde schon geparst, kann nicht noch einmal");

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
		throw new PositionFehler(svg, glied_index);

	if (glied_index >= glieder_liste.length)
		throw new PositionFehler(svg, glied_index);

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
		throw new Fehler("Variablennamen unbekannt!");
	}

	return glieder_liste;
}

Glied[] baue_glied_Falls_Glied(Falls_BlockGlied glied, Glied[] glieder_liste, ulong glied_index)
{
	if ((glied_index + 2) >= glieder_liste.length)
	{
		writeln(glied_index, glieder_liste);
		throw new Fehler(
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
		throw new Fehler(
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
	if ((glieder_liste.length + 2) >= glieder_liste.length)
		throw new Exception("Das Wort SOOLANGE ist zu nahe am Ende...");

	if (glieder_liste[glied_index + 1].is_class!BlockGlied)
		glied.aktionen = (cast(BlockGlied) glieder_liste[glied_index + 1]).aktionen;
	else
		glied.aktionen ~= glieder_liste[glied_index + 1];

	glied.bedingung = glieder_liste[glied_index + 1];

	glieder_liste = glieder_liste.remove(glied_index + 2);
	glieder_liste = glieder_liste.remove(glied_index + 1);

	return glieder_liste;
}
