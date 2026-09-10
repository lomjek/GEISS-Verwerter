module baum_generator.finde_mpo;

import glied;
import fehler.parse_fehler;
import operatoren;
import variablen.wert;
import ext.klasse : instanceof;

import std.conv : to;

enum Aktion_Gewicht
{
  INVALID,

  FUNKTION_ABRUFEN,
  FUNTKION_ERSTELLEN,

  SOLANGE,

  FALLS_SONST,

  SETZE_VARIABLE,
  VARIABLE_ERSTELLEN,

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

  for (ulong idx = glieder_liste.length; idx > 0; idx--)
  {
    ulong i = idx - 1;
    Glied glied = glieder_liste[i];

    if (glied.ist_vollständig)
      continue;

    if (glied.instanceof!OperationGlied)
    {
      OperationGlied op_glied = cast(OperationGlied) glied;
      if (op_glied.operationenTyp in operatoren_Gewicht)
        (&current_mpo).passe_mpo_an(operatoren_Gewicht[op_glied.operationenTyp], i);
    }
    else if (glied.instanceof!Setze_Variable_Glied)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.SETZE_VARIABLE, i);
    else if (glied.instanceof!Falls_BlockGlied)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);
    else if (glied.instanceof!Sonst_BlockGlied)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.FALLS_SONST, i);
    else if (glied.instanceof!Solange_BlockGlied)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.SOLANGE, i);
    else if (glied.instanceof!WT_Glied)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.VARIABLE_ERSTELLEN, i);
    else if ((glied.instanceof!Erstelle_Variable_Glied) &&
      (cast(Erstelle_Variable_Glied) glied).wert_typ == WertTyp.FUNKTION)
      (&current_mpo).passe_mpo_an(Aktion_Gewicht.FUNTKION_ERSTELLEN, i);

  }

  if (current_mpo.value == 0)
    throw new Parse_Fehler("Kein MPO gefunden: " ~ glieder_liste.to!string);

  return current_mpo;
}
