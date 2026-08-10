module baum_generator.baum_generator;

import baum_generator.baue_glied;

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

	SOLANGE,

	FALLS_SONST,

	SETZE_VARIABLE,

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

	for (ulong i = 0; i < glieder_liste.length; i++)
	{
		Glied glied = glieder_liste[i];

		if (glied.instanceof!OperationGlied) // Könnte Klammer sein -> Subblock
		{
			OperatorenTyp op_typ = (cast(OperationGlied) glied).operationenTyp;

			if (KLAMMERN_AUF.canFind(op_typ))
			{
				depth++;
				continue; // TODO: Muss geändert werden wegen Klammern mismatch.
			}
			else if (KLAMMERN_ZU.canFind(op_typ))
			{
				if (depth == 0)
					throw new Parse_Fehler("Zu viele Klammern wurden geschlossen");

				if (op_typ == OperatorenTyp.KLAMMER_ZU)
				{
					if (matrix[depth - 1].length > 0 &&
						matrix[depth - 1][$ - 1].instanceof!Lese_Variable_Glied)
					{
						ListeWert_Glied argumente = generiere_liste(matrix[depth]);

						Lese_Variable_Glied lvg = cast(Lese_Variable_Glied) matrix[depth - 1][$ - 1];

						matrix[depth - 1][$ - 1] =
							new Funktion_Abrufen_Glied(lvg.var_name, argumente.werte);
					}
					else
					{
						Glied[] geparste_teil = generiere_linie(matrix[depth]);
						// Der geparste Teil sollte theoretisch nur ein lang sein...
						matrix[depth - 1] ~= geparste_teil;
					}
				}
				else if (op_typ == OperatorenTyp.ECKIGE_KLAMMER_ZU)
				{
					ListeWert_Glied geparste_teil = generiere_liste(matrix[depth]);
					matrix[depth - 1] ~= geparste_teil;
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

	if (depth != 0)
		throw new Parse_Fehler("Nicht alle Klammern wurden geschlossen.");

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
			throw new Parse_Fehler(
				"Schon zehn Mal hintereinander ist nichts gescheites geparst worden. Es sollte nie hierhin kommen.");
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
ListeWert_Glied generiere_liste(Glied[] glieder_liste)
{
	Glied[] werte;

	bool sollte_komma_sein = false;

	foreach (Glied glied; glieder_liste)
	{
		if (sollte_komma_sein)
		{
			if (glied.instanceof!OperationGlied && (cast(OperationGlied) glied)
				.operationenTyp == OperatorenTyp.KOMMA)
			{
				sollte_komma_sein = false;
				continue;
			}
			else
				throw new ListeSeparatorNichtGetrennt_Fehler();
		}
		else
		{
			if (glied.instanceof!OperationGlied && (cast(OperationGlied) glied)
				.operationenTyp == OperatorenTyp.KOMMA)
			{
				werte ~= new Wert_Glied(Wert(WertTyp.INVALID, null));
				sollte_komma_sein = false;
				continue;
			}
			else
				werte ~= glied;

			sollte_komma_sein = true;
		}
	}

	return new ListeWert_Glied(werte);
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
				throw new Parse_Fehler("Dieser Operator hat keine Option. Das nicht gut."); // TODO: Sollte nie hier sein.
		}
		else if (glied.instanceof!Setze_Variable_Glied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.SETZE_VARIABLE, i);
		else if (glied.instanceof!Falls_BlockGlied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);
		else if (glied.instanceof!Sonst_BlockGlied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);
		else if (glied.instanceof!Solange_BlockGlied)
			(&current_mpo).passe_mpo_an(Aktion_Gewicht.SOLANGE, i);

	}

	if (current_mpo.index == 0)
		throw new Parse_Fehler("Kein MPO gefunden");

	current_mpo.index -= 1;

	return current_mpo;
}
