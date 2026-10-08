module wert.wert;

import wert.wert_typ;

import liste;
import fehler;
import zahl;
import text;

// @ {} [] # \ || != ~

// WERT
struct Wert
{
  WertTyp typ;

  union {
    void* wert;

    Nzahl* nzahl;
    Gzahl* gzahl;
    Zahl* zahl;

    bool* wahrheit;

    Text* text;

    Liste* liste;

    //FUNKTION?
  }

  //MANUAL, system initalizer
  public pure nothrow @system @nogc
    this(WertTyp typ, void* wert)
    {
      this.typ = typ;
      this.wert = wert;
    }

  public pure nothrow @safe @nogc
    this(Nzahl* _nzahl){
      typ = WertTyp.NATÜRLICHE_ZAHL;
      nzahl = _nzahl;
    }

  public pure nothrow @safe @nogc
    this(Gzahl*  _gzahl){
      typ = WertTyp.GANZE_ZAHL;
      gzahl = _gzahl;
    }

  public pure nothrow @safe @nogc
    this(Zahl* _zahl){
      typ = WertTyp.ZAHL;
      this.zahl = _zahl;
    }

  public pure nothrow @safe @nogc
    this(bool* _wahrheit){
      this.typ = WertTyp.WAHRHEIT;
      this.wahrheit = _wahrheit;
    }

  public pure nothrow @safe @nogc
    this(Text* _text){
      this.typ = WertTyp.TEXT;
      this.text = _text;
    }

  public pure nothrow @safe @nogc
    this(Liste* liste){
      this.typ = WertTyp.LISTE;
      this.liste = liste;
    }

  public pure nothrow @trusted @nogc
    this(Wert nwert)
    {
      this.typ = nwert.typ;
      this.wert = nwert.wert;
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
          return (*this.liste).opCmp(*other.liste);
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

  bool opEquals(const Wert other){
    return this.opCmp(other) == 0;
  }
}

public bool ist_wahr(Wert wert)
{
  if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
    return true;

  //TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

  return false;
}
