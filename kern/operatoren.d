module operatoren;

import glied.operation_glied;

import fehler.parse_fehler;

import std.conv : to;

// @ {} [] # \ || != ~

enum OperatorenTyp : ubyte
{
  INVALID,

  PLUS,
  MINUS,
  MAL,
  GETEILT,
  HOCH, // TODO: Das existiert noch nicht...

  GLEICH,

  RÜCK_PFEIL,
  VOR_PFEIL,

  KLAMMER_AUF,
  KLAMMER_ZU,
  ECKIGE_KLAMMER_AUF,
  ECKIGE_KLAMMER_ZU,

  KLEINER_ALS,
  GRÖSSER_ALS,
  GRÖSSER_GLEICH,
  KLEINER_GLEICH,

  GESCHWUNGENE_KLAMMER_AUF,
  GESCHWUNGENE_KLAMMER_ZU,

  PUNKT,
  KOMMA,
  DOPPELPUNKT,
  SEMIKOLON,

  NEUE_LINIE,
  ANFANG_LINIE,
  TAB,

  ANFANG_KOMMENTAR,
  ENDE_KOMMENTAR,
  ANFANG_LINIE_KOMMENTAR,

  ANFÜGEN,
}

immutable dchar[OperatorenTyp] operatoren_chars = [
  OperatorenTyp.INVALID: '\0',

  OperatorenTyp.PLUS: '+',
  OperatorenTyp.MINUS: '-',
  OperatorenTyp.MAL: '*',
  OperatorenTyp.GETEILT: '/',
  OperatorenTyp.HOCH: '^',

  OperatorenTyp.GLEICH: '=',

  OperatorenTyp.RÜCK_PFEIL: '←',
  OperatorenTyp.VOR_PFEIL: '→',

  OperatorenTyp.KLAMMER_AUF: '(',
  OperatorenTyp.KLAMMER_ZU: ')',
  OperatorenTyp.ECKIGE_KLAMMER_AUF: '[',
  OperatorenTyp.ECKIGE_KLAMMER_ZU: ']',

  OperatorenTyp.KLEINER_ALS: '<',
  OperatorenTyp.GRÖSSER_ALS: '>',
  OperatorenTyp.GRÖSSER_GLEICH: '≥',
  OperatorenTyp.KLEINER_GLEICH: '≤',

  OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF: '{',
  OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU: '}',

  OperatorenTyp.PUNKT: '.',
  OperatorenTyp.KOMMA: ',',
  OperatorenTyp.DOPPELPUNKT: ':',
  OperatorenTyp.SEMIKOLON: ';',

  OperatorenTyp.NEUE_LINIE: '\n',
  OperatorenTyp.ANFANG_LINIE: '\r',
  OperatorenTyp.TAB: '\t',

  OperatorenTyp.ANFANG_KOMMENTAR: '«',
  OperatorenTyp.ENDE_KOMMENTAR: '»',
  OperatorenTyp.ANFANG_LINIE_KOMMENTAR: '¶',

  OperatorenTyp.ANFÜGEN: '↤',
];

/// Das sind Operatoren, welche keine andere Funktion haben, als dass sie separieren
immutable OperatorenTyp[] separatoren = [
  OperatorenTyp.NEUE_LINIE,
  OperatorenTyp.ANFANG_LINIE,
  OperatorenTyp.TAB,
  OperatorenTyp.INVALID,
  OperatorenTyp.SEMIKOLON,
];

immutable OperatorenTyp[] KLAMMERN_AUF = [
  OperatorenTyp.KLAMMER_AUF,
  OperatorenTyp.ECKIGE_KLAMMER_AUF,
  OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF // Ev brauche ich auch < kleiner als.
];

immutable OperatorenTyp[] KLAMMERN_ZU = [
  OperatorenTyp.KLAMMER_ZU,
  OperatorenTyp.ECKIGE_KLAMMER_ZU,
  OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU // Ev brauche ich auch > grösser als.
];

immutable OperatorenTyp[OperatorenTyp] JEWEILIG_SCHLIESSENDE_KLAMMER = [
  OperatorenTyp.KLAMMER_AUF: OperatorenTyp.KLAMMER_ZU,
  OperatorenTyp.ECKIGE_KLAMMER_AUF: OperatorenTyp.ECKIGE_KLAMMER_ZU,
  OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF: OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU
];

immutable(dstring[OperatorenTyp]) mehrteilige_operatoren = [
  OperatorenTyp.RÜCK_PFEIL: "<-",
  OperatorenTyp.VOR_PFEIL: "->",
  OperatorenTyp.ANFANG_KOMMENTAR: "/*",
  OperatorenTyp.ENDE_KOMMENTAR: "*/",
  OperatorenTyp.ANFANG_LINIE_KOMMENTAR: "//",

  OperatorenTyp.GRÖSSER_GLEICH: ">=",
  OperatorenTyp.KLEINER_GLEICH: "<=",

  OperatorenTyp.ANFÜGEN: "<+",
];

//MARK: FUNKTIONEN
OperatorenTyp char_zu_opt(dchar c)
{
  foreach (k, v; operatoren_chars)
  {
    if (v == c)
      return k;
  }
  return OperatorenTyp.INVALID;
}

bool wort_ist_op(dstring wort)
{
  if (wort.length != 1)
    return false;

  dchar gesucht = wort[0];

  foreach (OperatorenTyp opt, dchar character; operatoren_chars)
  {
    if (character == gesucht)
      return true;
  }

  return false;
}

/// Wir nehmen an, dass die dstring entries für die Operatoren aus einteiligen Teilen bestehen.
private pure
OperatorenTyp erstelle_multi_char_op(dstring[] wort_liste, ulong* wort_index)
{
  foreach (OperatorenTyp opt, dstring multi_char_op; mehrteilige_operatoren)
  {
    dstring ganzer_operator = "";
    size_t liste_index = *wort_index;

    for (ulong i = 0; i < multi_char_op.length; i++)
    {
      while (liste_index < wort_liste.length && wort_liste[liste_index].length == 0)
      {
        liste_index++;
      }

      if (liste_index >= wort_liste.length)
        return OperatorenTyp.INVALID;

      if (wort_liste[liste_index].length != 1)
        return OperatorenTyp.INVALID;

      ganzer_operator ~= wort_liste[liste_index];
      liste_index++;
    }

    if (ganzer_operator == multi_char_op)
    {
      *wort_index = liste_index - 1;
      return opt;
    }
  }

  return OperatorenTyp.INVALID;
}

OperationGlied wort_als_op(dstring[] wort_liste, ulong* wort_index)
{
  if (!wort_ist_op(wort_liste[*wort_index]))
    throw new Parse_Fehler(
      "Folgender Operator ist nicht korrekt: " ~ wort_liste[*wort_index].to!string);

  OperatorenTyp opt = erstelle_multi_char_op(wort_liste, wort_index);

  if (opt == OperatorenTyp.INVALID)
    opt = char_zu_opt((wort_liste[*wort_index])[0]);

  if (opt == OperatorenTyp.INVALID)
    throw new Parse_Fehler("Invalider Operator");

  return new OperationGlied(opt);
}
