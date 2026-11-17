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

public
string als_string(const ref Wert w, Str_conv_typ sct)
{
  string wert_str;
  final switch (w.typ)
  {
  case WertTyp.NATÜRLICHE_ZAHL:
    const Nzahl nz = *w.nzahl;
    wert_str = zahl.wandel.als_string(nz, sct);
    break;

  case WertTyp.GANZE_ZAHL:
    const Gzahl gz = *w.gzahl;
    wert_str = zahl.wandel.als_string(gz, sct);
    break;

  case WertTyp.ZAHL:
    const Zahl z = *w.zahl;
    wert_str = zahl.wandel.als_string(z, sct);
    break;

  case WertTyp.TEXT:
    if (sct != Str_conv_typ.AUSGABE)
      wert_str = "\"";

    wert_str ~= (*cast(Text*) w.wert).str;

    if (sct != Str_conv_typ.AUSGABE)
      wert_str ~= "\"";

    break;

  case WertTyp.WAHRHEIT:
    bool wahrheit = *w.wahrheit;
    wert_str = wahrheit ? "wahr" : "falsch";
    break;

  case WertTyp.LISTE:
    const Liste li = *w.liste;
    wert_str = li.toString; //TODO: ANDERE FUNKTION REINFETZEN
    break;

  case WertTyp.FUNKTION:
    if (sct != Str_conv_typ.AUSGABE)
      return "W(" ~ w.typ.to!string ~ ")";
    break;

  case WertTyp.INVALID:
    if (sct != Str_conv_typ.AUSGABE)
      return "W(" ~ w.typ.to!string ~ ")";
    break;
  }

  if (sct == Str_conv_typ.AUSGABE)
    return wert_str;

  return "W(" ~ w.typ.to!string ~ " | " ~ wert_str ~ ")";
}
