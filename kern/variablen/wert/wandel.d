module wert.wandel;

import ext.prints : Str_conv_typ;

import wert.wert;
import wert.wert_typ;

import liste;
import fehler;
import zahl;
import text;

import std.conv : to;

// @ {} [] # \ || != ~

string als_string(const ref Wert w, Str_conv_typ sct)
{
  string wert_str;
  if (w.typ == WertTyp.NATÜRLICHE_ZAHL)
  {
    const Nzahl nz = *w.nzahl;
    wert_str = zahl.wandel.als_string(nz, sct);
  }
  else if (w.typ == WertTyp.GANZE_ZAHL)
  {
    const Gzahl gz = *w.gzahl;
    wert_str = zahl.wandel.als_string(gz, sct);
  }
  else if (w.typ == WertTyp.ZAHL)
  {
    const Zahl z = *w.zahl;
    wert_str = zahl.wandel.als_string(z, sct);
  }
  else if (w.typ == WertTyp.TEXT)
  {
    if (sct != Str_conv_typ.AUSGABE)
      wert_str = "\"";

    wert_str ~= (*cast(Text*) w.wert).str;

    if (sct != Str_conv_typ.AUSGABE)
      wert_str ~= "\"";
  }
  else if (w.typ == WertTyp.WAHRHEIT)
  {
    bool wahrheit = *w.wahrheit;
    wert_str = wahrheit ? "wahr" : "falsch";
  }
  else {
    if (sct != Str_conv_typ.AUSGABE)
      return "W(" ~ w.typ.to!string ~ ")";
  }

  if (sct == Str_conv_typ.AUSGABE)
    return wert_str;

  return "W(" ~ w.typ.to!string ~ " | " ~ wert_str ~ ")";
}

