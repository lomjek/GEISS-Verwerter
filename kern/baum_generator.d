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

private enum Operation_priorities
{
	INVALID,

	FUNKTION_ABRUFEN,

	SONST,
	FALLS,

	SOLANGE,

	SETZE_VARIABLE,

	GLEICH,
	GRÖSSER_ALS,
	KLEINER_ALS,

	PLUS_MINUS,
	MAL_DURCH,
	HOCH,

}

private uint get_op_prio_length()
{
	return Operation_priorities.max - Operation_priorities.min + 1;
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

// Finde die Anwendung mit max. Prioriäten;
ulong max_priority_operation = 0;
ulong max_priority_index = 0;

uint sonst_block_priority_addition = 0;
// Diese Variable ist dazu da, damit man die Sonst Blöcke von hinten nach 
// vorne parst, was wichtig ist für verkettungen.

uint klammer_zusatz = 0;
// Für den Zusatz an Priorität, wegen Klammern.

void passe_mpo_an(Operation_priorities op, ulong index)
{
	if (max_priority_operation < (op + klammer_zusatz + sonst_block_priority_addition))
	{
		max_priority_operation = Operation_priorities.PLUS_MINUS + klammer_zusatz + sonst_block_priority_addition;
		max_priority_index = index;
	}
}

Glied[] generiere_baum(Glied[] glieder_liste)
{
	debug
	{
		write("GL (2.0): ");
		set_pen_trait(TextTrait.fgGrey);
		writeln(glieder_liste);
		set_pen_trait(TextTrait.reset);
	}

	uint _Op_wiederholungen = 0;
	// Diese Variable ist dazu da, dass wenn der Parser keine Aktion findet,
	// aber der Baum noch nich abgeschlossen ist, er sich nicht in einer
	// endlosen Schleife verhaddert. 

	ulong arr_length = glieder_liste.length;

	uint klammern_offen = 0;
	// Diese Zahl ist dazu da, dass man zu der Maximalen priorität noch durch
	// Klamern einen Zusatz geben kann, also man kann die Priorität von Operationen 
	// wichtiger machen.

	uint geschw_klammern_offen = 0;
	Glied[] unter_block;
	// Diese zwei Variablen dienen dazu, dass man die Unterblöcke, welche mit
	// geschwungenen Klammern kennzeichnet rekrusiv abgerufen werden. 

	main_loop: while (!glieder_liste.ist_fertig) // Muss vermutlich geändert werden.
	{
		element_loop: for (ulong i = 0; i < arr_length; i++)
		{
			//MARK: Subblock bauen
			if (geschw_klammern_offen != 0)
			{
				if (glieder_liste[i].instanceof!OperationGlied)
				{
					OperationGlied op_gl = cast(OperationGlied) glieder_liste[i];
					if (op_gl.operationenTyp == OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF)
					{
						geschw_klammern_offen++;
					}
					else if (op_gl.operationenTyp == OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU)
					{
						geschw_klammern_offen--;
						if (geschw_klammern_offen == 0)
						{
							BlockGlied bl_gl = new BlockGlied;
							bl_gl.aktionen = generiere_baum(unter_block);

							glieder_liste[i] = bl_gl;
							unter_block = [];

							continue main_loop;
						}
					}
				}

				unter_block ~= glieder_liste[i];
				glieder_liste = glieder_liste.remove(i);
				arr_length--;
				i--;
				continue element_loop;
			}

			//MARK: Find MPO
			if (glieder_liste[i].ist_vollständig)
				continue;

			klammer_zusatz = (klammern_offen * get_op_prio_length);

			if (glieder_liste[i].instanceof!OperationGlied)
			{
				OperationGlied opg = cast(OperationGlied) glieder_liste[i];

			op_typ_switch:
				switch (opg.operationenTyp)
				{
				case OperatorenTyp.KLAMMER_AUF:
					if (i > 0)
					{
						if (glieder_liste[i - 1].instanceof!Lese_Variable_Glied)
						{
							Glied[] argumente = konstruiere_argumente(glieder_liste, i);

							Glied[] präfix = glieder_liste[0 .. i - 1];
							Glied[] suffix = glieder_liste[(i + argumente.length + 2) .. $];

							Funktion_Abrufen_Glied fag = new Funktion_Abrufen_Glied(
								(cast(Lese_Variable_Glied) glieder_liste[i - 1])
									.var_name,
									argumente
							);

							glieder_liste = präfix ~ fag ~ suffix;

							debug
							{
								write("GL (2.F): ");

								set_pen_trait(TextTrait.fgGrey);
								writeln(glieder_liste);
								set_pen_trait(TextTrait.reset);
							}

							arr_length = glieder_liste.length;
							i--;
							continue main_loop;
						}

					}

					klammern_offen++;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue main_loop;

				case OperatorenTyp.KLAMMER_ZU:
					klammern_offen--;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue main_loop;

				case OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF:
					geschw_klammern_offen++;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue main_loop;

				case OperatorenTyp.PLUS:
				case OperatorenTyp.MINUS:
					passe_mpo_an(Operation_priorities.PLUS_MINUS, i);
					break op_typ_switch;

				case OperatorenTyp.MAL:
				case OperatorenTyp.GETEILT:
					passe_mpo_an(Operation_priorities.MAL_DURCH, i);
					break op_typ_switch;

				case OperatorenTyp.HOCH:
					passe_mpo_an(Operation_priorities.HOCH, i);
					break op_typ_switch;

				case OperatorenTyp.GLEICH:
					passe_mpo_an(Operation_priorities.GLEICH, i);
					break op_typ_switch;

				case OperatorenTyp.GRÖSSER_ALS:
					passe_mpo_an(Operation_priorities.GRÖSSER_ALS, i);
					break op_typ_switch;

				case OperatorenTyp.KLEINER_ALS:
					passe_mpo_an(Operation_priorities.KLEINER_ALS, i);
					break op_typ_switch;

				default:
					break op_typ_switch;
				}
			}
			else if (glieder_liste[i].instanceof!Setze_Variable_Glied)
			{
				if (max_priority_operation < (
						Operation_priorities.SETZE_VARIABLE + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.SETZE_VARIABLE + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
			}
			else if (glieder_liste[i].instanceof!SW_Glied)
			{
				SchlüsselWort sw = (cast(SW_Glied) glieder_liste[i])
					.sw;
				if (sw == SchlüsselWort.FALLS)
				{
					if ((i + 2) >= arr_length)
					{
						throw new Exception(
							"Das Wort Falls ist zu nahe am Ende...");
					}

					if (max_priority_operation < (
							Operation_priorities.FALLS + klammer_zusatz + sonst_block_priority_addition))
					{
						max_priority_operation = Operation_priorities.FALLS + klammer_zusatz + sonst_block_priority_addition;
						max_priority_index = i;
					}
				}
				else if (sw == SchlüsselWort.SONST)
				{
					if ((i + 1) >= arr_length)
					{
						throw new Exception(
							"Das Wort Sonst ist zu nahe am Ende...");
					}

					if (max_priority_operation < (
							Operation_priorities.SONST + klammer_zusatz + sonst_block_priority_addition))
					{
						max_priority_operation = Operation_priorities.SONST + klammer_zusatz + sonst_block_priority_addition;
						sonst_block_priority_addition++;
						max_priority_index = i;
					}
				}
				else if (sw == SchlüsselWort.SOLANGE)
				{
					if ((i + 2) >= arr_length)
					{
						throw new Exception(
							"Das Wort Solange ist zu nahe am Ende...");
					}

					if (max_priority_operation < (
							Operation_priorities.SONST + klammer_zusatz + sonst_block_priority_addition))
					{
						max_priority_operation = Operation_priorities.SONST + klammer_zusatz + sonst_block_priority_addition;
						max_priority_index = i;
					}
				}
			}
		}

		Glied glied = glieder_liste[max_priority_index];

		if (max_priority_index == 0 && max_priority_operation == 0)
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

		debug
		{
			set_pen_trait(TextTrait.fgGrey);
			write("MPO "); //MAX PRIO OP
			write(max_priority_operation);
			write(" an index ");
			write(max_priority_index);
			write(" in List ");
			writeln(glieder_liste);
			set_pen_trait(
				TextTrait.reset);
		}

		//MARK: Build that node
		if (glied.instanceof!Wert_Glied)
		{
			//TODO: Es sollte eigentlich nie hier ankommen.
			// Exception?
			continue;
		}

		if (glied.instanceof!OperationGlied)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;

			if (!(max_priority_index > 0 && max_priority_index < (
					arr_length - 1)))
			{
				throw new Fehler(
					"Die Operation ist zu weit vorne oder zu weit hinten..."d);
			}

			Glied gl1 = glieder_liste[max_priority_index - 1];
			Glied gl2 = glieder_liste[max_priority_index + 1];
			// Falls die Operationen nicht immer die zwei Objekte daneben einnehmen sollen, muss hier ein if  Block hin
			op_glied.werte ~= gl1;
			op_glied.werte ~= gl2;
			op_glied.populated = true;

			glieder_liste[max_priority_index] = op_glied;
			glieder_liste = glieder_liste.remove(
				max_priority_index + 1);
			glieder_liste = glieder_liste.remove(
				max_priority_index - 1);
			arr_length -= 2;
			continue;
		}

		if (glied.instanceof!Setze_Variable_Glied)
		{
			Setze_Variable_Glied svglied = cast(
				Setze_Variable_Glied) glied;

			if (max_priority_index < 1)
				throw new PositionFehler(glied, max_priority_index);

			if (max_priority_index >= glieder_liste.length)
				throw new Exception("Der Pfeil kann nicht das letzte Element der Linie sein");

			Glied vorher_glied = glieder_liste[max_priority_index - 1];
			Glied naher_glied = glieder_liste[max_priority_index + 1];

			if (vorher_glied.instanceof!Erstelle_Variable_Glied)
			{
				Erstelle_Variable_Glied evg = cast(
					Erstelle_Variable_Glied) vorher_glied;
				svglied.var_name = evg.var_name;
				svglied.assign_wert = naher_glied;
				glieder_liste = glieder_liste.remove(
					max_priority_index + 1);
				arr_length--;
			}
			else if (vorher_glied.instanceof!Lese_Variable_Glied)
			{
				Lese_Variable_Glied lvg = cast(
					Lese_Variable_Glied) vorher_glied;
				svglied.var_name = lvg.var_name;
				svglied.assign_wert = naher_glied;

				glieder_liste = glieder_liste.remove(max_priority_index + 1);
				glieder_liste = glieder_liste.remove(max_priority_index - 1);

				arr_length -= 2;
			}
			else
			{
				throw new Exception("Variablennamen unbekannt!");
			}
		}

		if (glied.instanceof!SW_Glied)
		{
			SchlüsselWort sw = (
				cast(SW_Glied) glied).sw;
			if (sw == SchlüsselWort.FALLS)
			{
				if (
					(max_priority_index + 2) >= arr_length)
				{
					throw new Exception(
						"Das Wort Falls ist zu nahe am Ende...");
				}

				Falls_BlockGlied falls_block_glied = new Falls_BlockGlied();
				falls_block_glied.aktionen = (cast(
						BlockGlied) glieder_liste[max_priority_index + 2])
					.aktionen;
				falls_block_glied.bedingung = glieder_liste[max_priority_index + 1];

				glieder_liste[max_priority_index] = falls_block_glied;
				glieder_liste = glieder_liste.remove(
					max_priority_index + 2);
				glieder_liste = glieder_liste.remove(
					max_priority_index + 1);
				arr_length -= 2;
			}
			else if (sw == SchlüsselWort.SONST)
			{
				if (
					(max_priority_index + 1) >= arr_length)
				{
					throw new Exception(
						"Das Wort Sonst ist zu nahe am Ende...");
				}
				if (glieder_liste[max_priority_index + 1].instanceof!BlockGlied)
				{
					Sonst_BlockGlied sonst_block = new Sonst_BlockGlied();
					sonst_block.aktionen = (
						cast(BlockGlied) glieder_liste[max_priority_index + 1])
						.aktionen;

					glieder_liste[max_priority_index] = sonst_block;
					glieder_liste = glieder_liste.remove(
						max_priority_index + 1);
					arr_length--;
				}
				else if (glieder_liste[max_priority_index + 1].instanceof!Falls_BlockGlied)
				{
					Sonst_BlockGlied sonst_block = new Sonst_BlockGlied();
					sonst_block.aktionen ~= glieder_liste[max_priority_index + 1];

					glieder_liste[max_priority_index] = sonst_block;
					glieder_liste = glieder_liste.remove(
						max_priority_index + 1);
					arr_length--;
				}
				else
				{
					throw new Fehler("Das nächste Glied hat nicht den Richtigen Typ, es ist "d ~ glieder_liste[max_priority_index + 1]
							.toString.to!dstring);
				}
			}
			else if (sw == SchlüsselWort.SOLANGE)
			{
				if (
					(max_priority_index + 2) >= arr_length)
				{
					throw new Exception(
						"Das Wort SOOLANGE ist zu nahe am Ende...");
				}

				Solange_BlockGlied solange_block_glied = new Solange_BlockGlied();
				solange_block_glied.aktionen = (cast(
						BlockGlied) glieder_liste[max_priority_index + 2])
					.aktionen;
				solange_block_glied.bedingung = glieder_liste[max_priority_index + 1];

				glieder_liste[max_priority_index] = solange_block_glied;
				glieder_liste = glieder_liste.remove(
					max_priority_index + 2);
				glieder_liste = glieder_liste.remove(
					max_priority_index + 1);
				arr_length -= 2;
			}
		}

		//Zusammenziehen von Falls_Sonst Blocks
		for (ulong i = 0; (i + 1) < arr_length; i++)
		{
			if (glieder_liste[i].instanceof!Falls_BlockGlied &&
				glieder_liste[i + 1].instanceof!Sonst_BlockGlied)
			{
				Falls_BlockGlied fbgl = cast(Falls_BlockGlied) glieder_liste[i];
				Sonst_BlockGlied sbgl = cast(Sonst_BlockGlied) glieder_liste[i + 1];

				Falls_Sonst_BlockGlied fsbgl = new Falls_Sonst_BlockGlied(fbgl, sbgl);

				glieder_liste[i] = fsbgl;
				glieder_liste = glieder_liste.remove(i + 1);
				arr_length--;
				continue;
			}
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
			else if ((cast(OperationGlied) glied).operationenTyp == OperatorenTyp.ECKIGE_KLAMMER_ZU)
			{
				if (eckige_klammern_offen == 0)
					throw new Fehler("Es werden mehr Klammern zu als aufgemacht.");

				eckige_klammern_offen--;
				neue_gl[eckige_klammern_offen] ~= liste_erstellen(neue_gl[eckige_klammern_offen + 1]);
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

//MARK: Argumente Parsing

//TODO: Muss noch richtig umgesetzt werden.
Glied[] konstruiere_argumente(Glied[] glieder_liste, ulong klammer_auf_position)
{
	if (glieder_liste.length > klammer_auf_position + 1 &&
		glieder_liste[klammer_auf_position + 1].instanceof!OperationGlied &&
		(cast(OperationGlied) glieder_liste[klammer_auf_position + 1])
		.operationenTyp == OperatorenTyp
		.KLAMMER_ZU)
	{
		return [];
	}

	else if (glieder_liste.length > klammer_auf_position + 2 &&
		glieder_liste[klammer_auf_position + 2].instanceof!OperationGlied &&
		(cast(OperationGlied) glieder_liste[klammer_auf_position + 2])
		.operationenTyp == OperatorenTyp
		.KLAMMER_ZU)
	{
		return [glieder_liste[klammer_auf_position + 1]];
	}

	throw new Error("Not implemented!");
}
