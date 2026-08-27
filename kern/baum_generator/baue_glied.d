module baum_generator.baue_glied;

import ext.klasse;
import glied;
import variablen.wert;
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

  else if (glied.is_class!WT_Glied)
    return baue_glied_Erstelle_Variable_Glied(cast(WT_Glied) glied, glieder_liste, glied_index);

  else if (glied.is_class!Erstelle_Variable_Glied)
    return baue_glied_FunktionErstellen_Glied(cast(Erstelle_Variable_Glied) glied, glieder_liste, glied_index);

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

Glied[] baue_glied_Erstelle_Variable_Glied(WT_Glied glied, Glied[] glieder_liste, ulong glied_index)
{
  if ((glied_index + 1) >= glieder_liste.length)
    throw new Parse_Fehler("Das WT_Glied ist zu nahe am Ende...");

  if (glieder_liste[glied_index + 1].is_class!Lese_Variable_Glied)
  {
    dstring var_name = (cast(Lese_Variable_Glied) glieder_liste[glied_index + 1]).var_name;
    glieder_liste[glied_index] = new Erstelle_Variable_Glied(var_name, glied.vt);
    glieder_liste = glieder_liste.remove(glied_index + 1);

    return glieder_liste;
  }
  else if (glieder_liste[glied_index + 1].is_class!Funktion_Abrufen_Glied)
  {
    Funktion_Abrufen_Glied vg = cast(Funktion_Abrufen_Glied) glieder_liste[glied_index + 1]; 
    Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied(vg.identifier, WertTyp.FUNKTION);
    glieder_liste[glied_index] = evg;
    glieder_liste[glied_index + 1] = new ListeWert_Glied(vg.argumente); 
    return baue_glied_FunktionErstellen_Glied(evg, glieder_liste, glied_index);
  }
  else throw new Parse_Fehler(glieder_liste[glied_index + 1].toString); 
}

Glied[] baue_glied_FunktionErstellen_Glied(Erstelle_Variable_Glied glied, Glied[] glieder_liste, ulong glied_index)
{
  if ((glied_index + 1) >= glieder_liste.length)
    throw new Parse_Fehler("Die deklaration der Funktion ist zu nahe am Ende...");

  if (glieder_liste[glied_index + 1].is_class!BlockGlied)
  {
    glieder_liste[glied_index] = new FunktionErstellen_Glied(cast(BlockGlied) glieder_liste[glied_index + 1], glied.var_name);
    glieder_liste = glieder_liste.remove(glied_index + 1);
    return glieder_liste;
  }
 
  if ((glied_index + 2) >= glieder_liste.length)
    throw new Parse_Fehler("Die deklaration der Funktion ist zu nahe am Ende... (2)");

  if (glieder_liste[glied_index + 1].is_class!ListeWert_Glied &&
      glieder_liste[glied_index + 2].is_class!BlockGlied)
  {
    Glied[] parameter_liste = (cast(ListeWert_Glied) glieder_liste[glied_index + 1]).werte;
    Erstelle_Variable_Glied[] parameter;

    foreach (Glied parameter_glied; parameter_liste)
    {
      if (!glied.is_class!Erstelle_Variable_Glied)
        throw new Parse_Fehler("Die Parameter sind nicht gültig");

      parameter ~= cast(Erstelle_Variable_Glied) parameter_glied;
    }

    glieder_liste[glied_index] = new FunktionErstellen_Glied(cast(BlockGlied) glieder_liste[glied_index + 2], glied.var_name, parameter);
    glieder_liste = glieder_liste.remove(glied_index + 2);
    glieder_liste = glieder_liste.remove(glied_index + 1);
    return glieder_liste;
  }

  throw new Fehler("Leider noch kein support für Argumente / Returns");
}

