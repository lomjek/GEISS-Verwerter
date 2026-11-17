module wert.wert_typ;

import glied.wert_glied : WT_Glied;
import fehler.parse_fehler;

import std.conv : to;

// @ {} [] # \ || != ~

// Wert Typ
enum WertTyp
{
  INVALID,

  ZAHL,
  GANZE_ZAHL,
  NATÜRLICHE_ZAHL,

  WAHRHEIT,

  TEXT,

  LISTE,

  FUNKTION
}

const WertTyp[] ZAHLEN_TYPEN = [
  WertTyp.GANZE_ZAHL,
  WertTyp.NATÜRLICHE_ZAHL,
  WertTyp.ZAHL
];

immutable(dstring[WertTyp]) wertTypString = [
  WertTyp.INVALID: "variable"d,

  WertTyp.ZAHL: "zahl"d,
  WertTyp.GANZE_ZAHL: "gzahl"d,
  WertTyp.NATÜRLICHE_ZAHL: "nzahl"d,

  WertTyp.WAHRHEIT: "wahrheit"d,

  WertTyp.TEXT: "text"d,

  WertTyp.LISTE: "liste"d,

  WertTyp.FUNKTION: "funktion"d
];

immutable(dstring[][WertTyp]) multi_wort_wert_typ = [
  WertTyp.GANZE_ZAHL: ["ganze"d, "zahl"d],
  WertTyp.NATÜRLICHE_ZAHL: ["natürliche"d, "zahl"d]
];

//region Leser_Funktionen
WertTyp dstring_als_wt(dstring wort)
{
  foreach (WertTyp wt, dstring str; wertTypString)
  {
    if (str == wort)
      return wt;
  }

  return WertTyp.INVALID;
}

bool wort_ist_wert_typ(dstring wort)
{
  foreach (WertTyp wt, dstring str; wertTypString)
  {
    if (str == wort)
      return true;
  }

  foreach (WertTyp wt, immutable dstring[] strs; multi_wort_wert_typ)
  {
    if (strs[0] == wort)
      return true;
  }

  return false;
}

private pure
WertTyp erstelle_multi_wort_wert_typ(dstring[] wort_liste, ulong* wort_index)
{
  foreach (WertTyp wt, immutable dstring[] strs; multi_wort_wert_typ)
  {
    if (*wort_index + strs.length > wort_liste.length)
      continue; // Wenn das multi_wort_wt länger ist als restliche Glieder, beende früher.

    dstring[] ganzer_wt = [];
    for (ulong i = 0; i < strs.length; i++)
    {
      ganzer_wt ~= wort_liste[*wort_index + i];
    }

    if (ganzer_wt == strs)
    {
      *wort_index += ganzer_wt.length - 1;
      return wt;
    }
  }

  return WertTyp.INVALID;
}

WT_Glied wort_als_wert_typ(dstring[] wort_liste, ulong* wort_index)
{
  WertTyp wt = erstelle_multi_wort_wert_typ(wort_liste, wort_index);

  if (wt == WertTyp.INVALID)
    wt = dstring_als_wt(wort_liste[*wort_index]);

  if (wt == WertTyp.INVALID && wort_liste[*wort_index] != "variable"d)
    throw new Parse_Fehler(
      "Das Wort ist kein valides WertTyp: " ~ wort_liste[*wort_index].to!string);

  return new WT_Glied(wt);
}
//endregion
