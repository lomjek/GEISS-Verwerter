module schlüsselwörter;

import ext.string : strip;

import glied.glied : SW_Glied, Glied, Nicht_Glied;
import glied.block_glied : Falls_BlockGlied, Sonst_BlockGlied;
import glied.schleife_glied : Solange_BlockGlied, Wiederhole_BlockGlied;
import glied.signal_glied : Beende_Programm_Glied, Beende_Funktion_Glied;

import fehler.parse_fehler : Parse_Fehler;

import std.conv : to;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
  INVALID,

  PRO,
  DER,

  FALLS,
  SONST,

  SOLANGE,
  NICHT,

  WIEDERHOLE,
  MAL,

  BEENDE_FUNKTION,
  BEENDE_PROGRAMM,
}

immutable dstring[SchlüsselWort] schlüsselWort_dict = [
  SchlüsselWort.PRO: "pro"d,
  SchlüsselWort.DER: "von"d,

  SchlüsselWort.FALLS: "falls"d,
  SchlüsselWort.SONST: "sonst"d,

  SchlüsselWort.SOLANGE: "solange"d,
  SchlüsselWort.NICHT: "nicht"d,

  SchlüsselWort.WIEDERHOLE: "wiederhole"d,
  SchlüsselWort.MAL: "mal"d,
];

immutable(dstring[][SchlüsselWort]) multi_wort_sw = [
  SchlüsselWort.BEENDE_FUNKTION: ["beende"d, "funktion"d],
  SchlüsselWort.BEENDE_PROGRAMM: ["beende"d, "programm"d],
];

//region Leser_Funktionen
SchlüsselWort dstring_als_sw(dstring wort)
{
  foreach (SchlüsselWort sw, dstring str; schlüsselWort_dict)
  {
    if (str == wort)
      return sw;
  }

  return SchlüsselWort.INVALID;
}

Glied baue_richtiges_sw_glied(SchlüsselWort sw)
{
  switch (sw)
  {
  case SchlüsselWort.FALLS:
    return new Falls_BlockGlied();

  case SchlüsselWort.SONST:
    return new Sonst_BlockGlied();

  case SchlüsselWort.SOLANGE:
    return new Solange_BlockGlied();

  case SchlüsselWort.WIEDERHOLE:
    return new Wiederhole_BlockGlied();

  case SchlüsselWort.BEENDE_FUNKTION:
    return new Beende_Funktion_Glied();

  case SchlüsselWort.BEENDE_PROGRAMM:
    return new Beende_Programm_Glied();

  case SchlüsselWort.NICHT:
    return new Nicht_Glied();

  default:
    return new SW_Glied(sw);
  }
}

bool wort_ist_sw(dstring wort)
{
  foreach (SchlüsselWort sw, dstring str; schlüsselWort_dict)
  {
    if (str == wort)
      return true;
  }

  foreach (SchlüsselWort sw, immutable dstring[] strs; multi_wort_sw)
  {
    if (strs[0] == wort)
      return true;
  }

  return false;
}

private pure
SchlüsselWort erstelle_multi_wort_schlüsselwort(dstring[] wort_liste, ulong* wort_index)
{
  foreach (SchlüsselWort sw, immutable dstring[] strs; multi_wort_sw)
  {
    dstring[] ganzer_sw = [];
    size_t liste_index = *wort_index;

    for (ulong i = 0; i < multi_wort_sw.length; i++)
    {
      while (liste_index < wort_liste.length && wort_liste[liste_index].length == 0)
      {
        liste_index++;
      }

      ganzer_sw ~= wort_liste[liste_index].strip;
      liste_index++;
    }

    if (ganzer_sw == strs)
    {
      *wort_index += liste_index;
      return sw;
    }
  }

  return SchlüsselWort.INVALID;
}

Glied wort_als_sw(dstring[] wort_liste, ulong* wort_index)
{
  SchlüsselWort sw = erstelle_multi_wort_schlüsselwort(wort_liste, wort_index);

  if (sw == SchlüsselWort.INVALID)
    sw = dstring_als_sw(wort_liste[*wort_index].strip);

  if (sw == SchlüsselWort.INVALID)
    throw new Parse_Fehler(
      "Das Wort ist kein valides SchlüsselWort: " ~ wort_liste[*wort_index].to!string);

  return baue_richtiges_sw_glied(sw);
}
