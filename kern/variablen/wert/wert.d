module wert.wert;

import wert.wert_typ;

import liste;
import fehler;
import zahl;
import text;

import std.conv : to;

// @ {} [] # \ || != ~

// WERT
struct Wert
{
  WertTyp typ;

  union
  {
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
  this(Nzahl* _nzahl)
  {
    typ = WertTyp.NATÜRLICHE_ZAHL;
    nzahl = _nzahl;
  }

  public pure nothrow @safe @nogc
  this(Gzahl* _gzahl)
  {
    typ = WertTyp.GANZE_ZAHL;
    gzahl = _gzahl;
  }

  public pure nothrow @safe @nogc
  this(Zahl* _zahl)
  {
    typ = WertTyp.ZAHL;
    this.zahl = _zahl;
  }

  public pure nothrow @safe @nogc
  this(bool* _wahrheit)
  {
    this.typ = WertTyp.WAHRHEIT;
    this.wahrheit = _wahrheit;
  }

  public pure nothrow @safe @nogc
  this(Text* _text)
  {
    this.typ = WertTyp.TEXT;
    this.text = _text;
  }

  public pure nothrow @safe @nogc
  this(Liste* liste)
  {
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
    if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.GANZE_ZAHL)
      return (*this.zahl).opCmp(Zahl(*other.zahl));

    else if (this.typ == WertTyp.GANZE_ZAHL && other.typ == WertTyp.ZAHL)
      return (Zahl(*this.gzahl).opCmp(*other.zahl));

    else if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL)
      return (*this.zahl).opCmp(Zahl(*other.nzahl));

    else if (this.typ == WertTyp.NATÜRLICHE_ZAHL && other.typ == WertTyp.ZAHL)
      return (Zahl(*this.nzahl).opCmp(*other.zahl));

    else if (this.typ == WertTyp.GANZE_ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL)
      return (*cast(Gzahl*) this.wert).opCmp(Gzahl(*cast(Nzahl*) other.wert));

    else if (this.typ == WertTyp.NATÜRLICHE_ZAHL && other.typ == WertTyp.GANZE_ZAHL)
      return Gzahl(*this.nzahl).opCmp(*other.gzahl);

    if (this.typ == other.typ)
    {
      final switch (this.typ)
      {
      case WertTyp.ZAHL:
        return (*this.zahl).opCmp(*cast(Zahl*) other.wert);
      case WertTyp.GANZE_ZAHL:
        return (*cast(Gzahl*) this.wert).opCmp(
          *cast(Gzahl*) other.wert);
      case WertTyp.NATÜRLICHE_ZAHL:
        return (*cast(Nzahl*) this.wert)
          .opCmp(*cast(Nzahl*) other.wert);
      case WertTyp.TEXT:
        return (*cast(Text*) this.wert).opCmp(*cast(Text*) other.wert);
      case WertTyp.LISTE:
        return (*this.liste).opCmp(*other.liste);
      case WertTyp.FUNKTION:
        return -3; // TODO: Sich ein System überlegen, wie man Funktionen vergleichen kann, wenn man Sie überhaupt vergleichen kann.
      case WertTyp.WAHRHEIT:
        if (*cast(bool*) this.wert == *cast(bool*) other.wert)
          return 0;
        return *cast(bool*) this.wert ? 1 : -1;
      case WertTyp.INVALID:
        return -4;
      }
    }

    if (this.typ != other.typ)
    {
      throw new Fehler("TypenFehler: Man kann nicht Wert mit typ " ~ " und " ~ " vergleichen");
    }

    return -2;
  }

  bool opEquals(const Wert other) const
  {
    return this.opCmp(other) == 0;
  }

  Wert opBinary(string op, T)(T other)
  {
    static if (!is(T == Wert))
      throw new Fehler("Man sollte diesen Ort nie erreichen. Wert wird nicht mit Wert addiert");

    if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.GANZE_ZAHL)
      return Wert(new Zahl((*this.zahl).opBinary!op(Zahl(*other.zahl))));

    else if (this.typ == WertTyp.GANZE_ZAHL && other.typ == WertTyp.ZAHL)
      return Wert(new Zahl(Zahl(*this.gzahl).opBinary!op(*other.zahl)));

    else if (this.typ == WertTyp.ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL)
      return Wert(new Zahl((*this.zahl).opBinary!op(Zahl(*other.nzahl))));

    else if (this.typ == WertTyp.NATÜRLICHE_ZAHL && other.typ == WertTyp.ZAHL)
      return Wert(new Zahl(Zahl(*this.nzahl).opBinary!op(*other.zahl)));

    else if (this.typ == WertTyp.GANZE_ZAHL && other.typ == WertTyp.NATÜRLICHE_ZAHL)
      return Wert(new Gzahl(this.gzahl.opBinary!op(Gzahl(*other.nzahl))));

    else if (this.typ == WertTyp.NATÜRLICHE_ZAHL && other.typ == WertTyp.GANZE_ZAHL)
      return Wert(new Gzahl(Gzahl(*this.nzahl).opBinary!op(*other.gzahl)));

    if (this.typ == other.typ)
    {
      final switch (this.typ)
      {
      case WertTyp.ZAHL:
        return Wert(new Zahl(this.zahl.opBinary!op(*other.zahl)));

      case WertTyp.GANZE_ZAHL:
        return Wert(new Gzahl(this.gzahl.opBinary!op(*other.gzahl)));

      case WertTyp.NATÜRLICHE_ZAHL:
        return Wert(new Nzahl(this.nzahl.opBinary!op(*other.nzahl)));

      case WertTyp.TEXT:
        return Wert(new Text(this.text.opBinary!op(*other.text)));

      case WertTyp.LISTE:
        return Wert(new Liste(this.liste.opBinary!op(*other.liste)));

      case WertTyp.FUNKTION:
        return Wert(); // TODO: Braucht es das?

      case WertTyp.WAHRHEIT:
        return Wert(new bool(false));

      case WertTyp.INVALID:
        return Wert();
      }
    }

    if (this.typ != other.typ)
    {
      throw new Fehler(
        "TypenFehler: Man kann nicht Wert mit typ " ~ this.typ.to!string ~
          " und " ~ other.typ.to!string ~ " vergleichen");
    }

    return Wert();
  }
}

public bool ist_wahr(Wert wert)
{
  if (wert.typ == WertTyp.WAHRHEIT && *cast(bool*) wert.wert)
    return true; //TODO: Hier noch alle anderen wahr/falsch Sachen reinmachen

  return false;
}
