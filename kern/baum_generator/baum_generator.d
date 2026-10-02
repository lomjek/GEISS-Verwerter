module baum_generator.baum_generator;

import baum_generator.baue_glied;
import baum_generator.finde_mpo;

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
  Glied[][] matrix = [[]];
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

        while (matrix.length <= depth) //Enlarge array
        {
          matrix.length = depth + 1;
        }
      }
      else if (KLAMMERN_ZU.canFind(op_typ))
      {
        if (depth == 0)
          throw new Parse_Fehler("Zu viele Klammern wurden geschlossen");

        OperatorenTyp auf_op_typ = (cast(OperationGlied) matrix[depth][0]).operationenTyp;

        if (JEWEILIG_SCHLIESSENDE_KLAMMER[auf_op_typ] != op_typ)
          throw new Parse_Fehler("Die Klammer wurde mit einer anderen Klammer zugemacht.");

        Glied[] rohe_glied_linie = (matrix[depth])[1 .. $];

        if (op_typ == OperatorenTyp.KLAMMER_ZU)
        {
          if (matrix[depth - 1].length > 0 &&  // Wenn argumente für funktion
              matrix[depth - 1][$ - 1].instanceof!Lese_Variable_Glied)
          {
            ListeWert_Glied argumente = generiere_liste(rohe_glied_linie);

            Lese_Variable_Glied lvg = cast(Lese_Variable_Glied) matrix[depth - 1][$ - 1];

            matrix[depth - 1][$ - 1] =
              new Funktion_Abrufen_Glied(lvg.var_name, argumente.werte);
          }
          else
          {
            Glied[] geparste_teil = generiere_linie(rohe_glied_linie);
            // Der geparste Teil sollte theoretisch nur ein lang sein...
            matrix[depth - 1] ~= geparste_teil;
          }
        }
        else if (op_typ == OperatorenTyp.ECKIGE_KLAMMER_ZU)
        {
          ListeWert_Glied geparste_teil = generiere_liste(rohe_glied_linie);

          if (geparste_teil.länge == 1 &&
              matrix[depth - 1].length > 0 &&  // Wenn ein sucher für Listen
              matrix[depth - 1][$ - 1].instanceof!Lese_Variable_Glied)
          {
            matrix[depth - 1][$ - 1] = new LiesListeElement_Glied(geparste_teil.werte[0], cast(Lese_Variable_Glied) matrix[depth - 1][$ - 1]);
          }
          else
            matrix[depth - 1] ~= geparste_teil;
        }
        else if (op_typ == OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU)
        {
          Glied[] geparste_teil = generiere_linie(rohe_glied_linie);
          matrix[depth - 1] ~= new BlockGlied(geparste_teil);
        }

        matrix[depth] = []; // Leere das jetzt nicht mehr benötigte array.

        depth--;
        continue;
      }
      // Ev. brauche ich noch Spitze Klammer zu für nacher. 
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

  Glied[] roher_zwischenwert;

  foreach (Glied glied; glieder_liste)
  {
    if (glied.instanceof!OperationGlied && (cast(OperationGlied) glied)
        .operationenTyp == OperatorenTyp.KOMMA)
    {
      if (roher_zwischenwert.length == 0)
        werte ~= new Wert_Glied(Wert(WertTyp.INVALID, null));

      else
      {
        Glied[] geparste_linie = generiere_linie(roher_zwischenwert);

        if (geparste_linie.length == 1)
        {
          werte ~= geparste_linie[0];
          roher_zwischenwert = [];
        }

        else
          throw new ListeSeparatorNichtGetrennt_Fehler();
      }
      continue;
    }

    roher_zwischenwert ~= glied;
  }

  if (roher_zwischenwert.length > 0)
  {
    Glied[] geparste_linie = generiere_linie(roher_zwischenwert);

    if (geparste_linie.length == 1)
      werte ~= geparste_linie[0];
    else
      throw new ListeSeparatorNichtGetrennt_Fehler();
  }

  return new ListeWert_Glied(werte);
}
