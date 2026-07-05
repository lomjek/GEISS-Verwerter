module baum_generator;

import operatoren;
import schlüsselwörter;
import ext.prints;

import liste;

import fehler;

import glied.glied;
import glied.wert_glied;
import glied.operation_glied;
import glied.block_glied;
import glied.variablen_glied;

import variablen.wert;

import std.algorithm : remove, canFind;
import std.stdio : writeln, write;
import std.conv : to;

// @ {} [] # \ || != ~

private enum Operation_priorities
{
	INVALID,

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
		if (glied.classinfo != OperationGlied.classinfo)
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
		if (glied.classinfo == OperationGlied.classinfo)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;
			if (op_glied.operationenTyp == OperatorenTyp.RÜCK_PFEIL)
			{
				glieder_liste[i] = new Setze_Variable_Glied();
			}

		}
		// WT_GLIED wird zu VAR_bauen node umgewandelt.
		else if (glied.classinfo == WT_Glied.classinfo && i + 1 < length &&
			glieder_liste[i + 1].classinfo == Lese_Variable_Glied.classinfo)
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
	debug
	{
		write("Gliederliste:");
		set_pen_trait(TextTrait.fgCyan);
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
		// Finde die Anwendung mit max. Prioriäten;
		ulong max_priority_operation = 0;
		ulong max_priority_index = 0;

		uint sonst_block_priority_addition = 0;

		element_loop: for (ulong i = 0; i < arr_length; i++)
		{
			//MARK: Subblock bauen
			if (geschw_klammern_offen != 0)
			{
				if (glieder_liste[i].classinfo == OperationGlied.classinfo)
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

			uint klammer_zusatz = (klammern_offen * get_op_prio_length);

			if (glieder_liste[i].classinfo == OperationGlied.classinfo)
			{
				OperationGlied opg = cast(OperationGlied) glieder_liste[i];

				if (opg.operationenTyp == OperatorenTyp.KLAMMER_AUF)
				{
					klammern_offen++;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue;
				}
				else if (opg.operationenTyp == OperatorenTyp.KLAMMER_ZU)
				{
					klammern_offen--;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue;
				}
				else if (opg.operationenTyp == OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF)
				{
					geschw_klammern_offen++;
					glieder_liste = glieder_liste.remove(i);
					arr_length--;
					i--;
					continue;
				}

				if ([OperatorenTyp.PLUS, OperatorenTyp.MINUS]
					.canFind(opg.operationenTyp) &&
					max_priority_operation < (
						Operation_priorities.PLUS_MINUS + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.PLUS_MINUS + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
				else if ([OperatorenTyp.MAL, OperatorenTyp.GETEILT]
					.canFind(opg.operationenTyp) &&
					max_priority_operation < (
						Operation_priorities.MAL_DURCH + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.MAL_DURCH + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
				else if (opg.operationenTyp == OperatorenTyp.HOCH &&
					max_priority_operation < (
						Operation_priorities.HOCH + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.HOCH + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
				else if (opg.operationenTyp == OperatorenTyp.GLEICH &&
					max_priority_operation < (
						Operation_priorities.GLEICH + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.GLEICH + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
				else if (opg.operationenTyp == OperatorenTyp.GRÖSSER_ALS)
				{
					max_priority_operation = Operation_priorities.GRÖSSER_ALS + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
				else if (opg.operationenTyp == OperatorenTyp.KLEINER_ALS)
				{
					max_priority_operation = Operation_priorities.KLEINER_ALS + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}

			}
			else if (glieder_liste[i].classinfo == Setze_Variable_Glied.classinfo)
			{
				if (max_priority_operation < (
						Operation_priorities.SETZE_VARIABLE + klammer_zusatz + sonst_block_priority_addition))
				{
					max_priority_operation = Operation_priorities.SETZE_VARIABLE + klammer_zusatz + sonst_block_priority_addition;
					max_priority_index = i;
				}
			}
			else if (glieder_liste[i].classinfo == SW_Glied.classinfo)
			{
				SchlüsselWort sw = (cast(SW_Glied) glieder_liste[i]).sw;

				if (sw == SchlüsselWort.FALLS)
				{
					if ((i + 2) >= arr_length)
					{
						throw new Exception("Das Wort Falls ist zu nahe am Ende...");
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
						throw new Exception("Das Wort Sonst ist zu nahe am Ende...");
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
						throw new Exception("Das Wort Solange ist zu nahe am Ende...");
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
			_Op_wiederholungen = 0;
		// Wenn man keine Operation findet, macht man diese Zahl grösser.
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
			set_pen_trait(TextTrait.reset);
		}

		//MARK: Build that node
		if (glied.classinfo == Wert_Glied.classinfo)
		{
			continue;
		}

		if (glied.classinfo == OperationGlied.classinfo)
		{
			OperationGlied op_glied = cast(OperationGlied) glied;

			if (!(max_priority_index > 0 && max_priority_index < (arr_length - 1)))
			{
				throw new Fehler("Die Operation ist zu weit vorne oder zu weit hinten..."d);
			}

			Glied gl1 = glieder_liste[max_priority_index - 1];
			Glied gl2 = glieder_liste[max_priority_index + 1];
			// Falls die Operationen nicht immer die zwei Objekte daneben einnehmen sollen, muss hier ein if  Block hin
			op_glied.werte ~= gl1;
			op_glied.werte ~= gl2;
			op_glied.populated = true;

			glieder_liste[max_priority_index] = op_glied;
			glieder_liste = glieder_liste.remove(max_priority_index + 1);
			glieder_liste = glieder_liste.remove(max_priority_index - 1);
			arr_length -= 2;
			continue;
		}

		if (glied.classinfo == Setze_Variable_Glied.classinfo)
		{
			Setze_Variable_Glied svglied = cast(Setze_Variable_Glied) glied;

			if (max_priority_index < 1)
				throw new Exception("Der Pfeil kann nicht das erste Ding der Linie sein...");

			if (max_priority_index >= glieder_liste.length)
				throw new Exception("Der Pfeil kann nicht das letzte Element der Linie sein");

			Glied vorher_glied = glieder_liste[max_priority_index - 1];
			Glied naher_glied = glieder_liste[max_priority_index + 1];

			if (vorher_glied.classinfo == Erstelle_Variable_Glied.classinfo)
			{
				Erstelle_Variable_Glied evg = cast(Erstelle_Variable_Glied) vorher_glied;
				svglied.var_name = evg.var_name;
				svglied.assign_wert = naher_glied;
				glieder_liste = glieder_liste.remove(max_priority_index + 1);
				arr_length--;
			}
			else if (vorher_glied.classinfo == Lese_Variable_Glied.classinfo)
			{
				Lese_Variable_Glied lvg = cast(Lese_Variable_Glied) vorher_glied;
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

		if (glied.classinfo == SW_Glied.classinfo)
		{
			SchlüsselWort sw = (cast(SW_Glied) glied).sw;
			if (sw == SchlüsselWort.FALLS)
			{
				if ((max_priority_index + 2) >= arr_length)
				{
					throw new Exception("Das Wort Falls ist zu nahe am Ende...");
				}

				Falls_BlockGlied falls_block_glied = new Falls_BlockGlied();
				falls_block_glied.aktionen = (cast(BlockGlied) glieder_liste[max_priority_index + 2])
					.aktionen;
				falls_block_glied.bedingung = glieder_liste[max_priority_index + 1];

				glieder_liste[max_priority_index] = falls_block_glied;
				glieder_liste = glieder_liste.remove(max_priority_index + 2);
				glieder_liste = glieder_liste.remove(max_priority_index + 1);
				arr_length -= 2;
			}
			else if (sw == SchlüsselWort.SONST)
			{
				if ((max_priority_index + 1) >= arr_length)
				{
					throw new Exception("Das Wort Sonst ist zu nahe am Ende...");
				}
				if (glieder_liste[max_priority_index + 1].classinfo == BlockGlied.classinfo)
				{
					Sonst_BlockGlied sonst_block = new Sonst_BlockGlied();
					sonst_block.aktionen = (cast(BlockGlied) glieder_liste[max_priority_index + 1])
						.aktionen;

					glieder_liste[max_priority_index] = sonst_block;
					glieder_liste = glieder_liste.remove(max_priority_index + 1);
					arr_length--;
				}
				else if ([
						Falls_BlockGlied.classinfo,
						Falls_Sonst_BlockGlied.classinfo
					].canFind(
						glieder_liste[max_priority_index + 1].classinfo))
				{
					Sonst_BlockGlied sonst_block = new Sonst_BlockGlied();
					sonst_block.aktionen ~= glieder_liste[max_priority_index + 1];

					glieder_liste[max_priority_index] = sonst_block;
					glieder_liste = glieder_liste.remove(max_priority_index + 1);
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
				if ((max_priority_index + 2) >= arr_length)
				{
					throw new Exception("Das Wort SOOLANGE ist zu nahe am Ende...");
				}

				Solange_BlockGlied solange_block_glied = new Solange_BlockGlied();
				solange_block_glied.aktionen = (cast(BlockGlied) glieder_liste[max_priority_index + 2])
					.aktionen;
				solange_block_glied.bedingung = glieder_liste[max_priority_index + 1];

				glieder_liste[max_priority_index] = solange_block_glied;
				glieder_liste = glieder_liste.remove(max_priority_index + 2);
				glieder_liste = glieder_liste.remove(max_priority_index + 1);
				arr_length -= 2;
			}
		}

		for (ulong i = 0; (i + 1) < arr_length; i++)
		{
			if (glieder_liste[i].classinfo == Falls_BlockGlied.classinfo &&
				glieder_liste[i + 1].classinfo == Sonst_BlockGlied.classinfo)
			{
				Falls_BlockGlied fbgl = cast(Falls_BlockGlied) glieder_liste[i];
				Sonst_BlockGlied sbgl = cast(Sonst_BlockGlied) glieder_liste[i + 1];

				Falls_Sonst_BlockGlied fsbgl = new Falls_Sonst_BlockGlied(fbgl, sbgl);

				glieder_liste[i] = fsbgl;
				glieder_liste = glieder_liste.remove(
					i + 1);
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
		if (glied.classinfo == OperationGlied.classinfo)
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
	ulong eckige_klammern_offen = 0; // TODO: Brauche ich dann für rekrusive Listen
	Glied[][] neue_gl;

	ulong arr_length = glieder_liste.length;

	for (ulong i = 0; i < arr_length; i++)
	{
		Glied glied = glieder_liste[i];

		if (glied.classinfo == OperationGlied.classinfo)
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
