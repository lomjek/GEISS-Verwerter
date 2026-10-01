module wert.wert;

import wert.wert_typ;

import std.conv : to;

import liste;
import fehler;
import zahl;
import text;

// @ {} [] # \ || != ~

// WERT
struct Wert
{
  WertTyp typ;
  void* wert;

  this(WertTyp typ, void* wert)
  {
    this.typ = typ;
    this.wert = wert;
  }

  this(Wert nwert)
  {
    this.typ = nwert.typ;
    this.wert = nwert.wert;
  }

  string toString() const
  {
    string wert_str;
    if (this.typ == WertTyp.NATÜRLICHE_ZAHL)
    {
      Nzahl nz = *cast(Nzahl*) this.wert;
      wert_str = nz.als_string;
    }
    else if (this.typ == WertTyp.GANZE_ZAHL)
    {
      Gzahl gz = *cast(Gzahl*) this.wert;
      wert_str = gz.als_string;
    }
    else if (this.typ == WertTyp.ZAHL)
    {
      Zahl z = *cast(Zahl*) this.wert;
      wert_str = z.als_string;
    }
    else if (this.typ == WertTyp.TEXT)
    {
      wert_str = "\"";
      wert_str ~= (*cast(Text*) this.wert).str;
      wert_str ~= "\"";
    }
    else if (this.typ == WertTyp.WAHRHEIT)
    {
      bool wahrheit = *cast(bool*) this.wert;
      wert_str = wahrheit ? "wahr" : "falsch";
    }
    else
      return "W(" ~ this.typ.to!string ~ ")";

    return "W(" ~ this.typ.to!string ~ " | " ~ wert_str ~ ")";
  }

  //MARK: opCmp
  int opCmp(const Wert other) const
  {
    if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.GANZE_ZAHL){
      return (*cast(Zahl*) this.wert).opCmp(Zahl(*cast(Gzahl*) other.wert));
    }
    else if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL){
      return (*cast(Zahl*) this.wert).opCmp(Zahl(*cast(Nzahl*) other.wert));
    }
    else if (this.typ == WertTyp.GANZE_ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL){
      return (*cast(Gzahl *) this.wert).opCmp(Gzahl(*cast(Nzahl *) other.wert));
    }
    
    if (this.typ == other.typ)
    {
      final switch (this.typ){
        case WertTyp.ZAHL:
          return (*cast(Zahl*) this.wert).opCmp(*cast(Zahl *) other.wert);
        case WertTyp.GANZE_ZAHL:
          return (*cast(Gzahl *) this.wert).opCmp(*cast(Gzahl *) other.wert);
        case WertTyp.NATÜRLICHE_ZAHL:
          return (*cast(Nzahl *) this.wert).opCmp(*cast(Nzahl *) other.wert);
        case WertTyp.TEXT:
          return (*cast(Text *) this.wert).opCmp(*cast(Text *) other.wert);
        case WertTyp.LISTE:
          return (*cast(Liste *) this.wert).opCmp(*cast(Liste *) other.wert);
        case WertTyp.FUNKTION:
          return -3; // TODO: Sich ein System überlegen, wie man Funktionen vergleichen kann, wenn man Sie überhaupt vergleichen kann.
        case WertTyp.WAHRHEIT:
          if (*cast(bool *) this.wert == *cast(bool *) other.wert) return 0;
          return *cast(bool *) this.wert ? 1 : -1;
        case WertTyp.INVALID:
          return -4;
      }
    }

    if (this.typ != other.typ){
      throw new Fehler("TypenFehler: Man kann nicht Wert mit typ " ~ " und " ~ " vergleichen");
    }

    return -2;
  }

}

public bool ist_wahr(Wert wert)
{
  if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
    return true;

  //TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

  return false;
}
