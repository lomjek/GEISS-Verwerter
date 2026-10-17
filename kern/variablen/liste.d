module liste;

import fehler;
import ext.prints;
import wert;

import std.conv : to;

// @ {} [] # \ || != ~

struct Liste
{
  WertTyp[] fix_wert_typ;
  Wert[] werte;

  this(const WertTyp[] fixer_wert_typ, Wert[] werte)
  {
    this.fix_wert_typ = fixer_wert_typ.dup;
    this.werte = werte;
  }

  this(Liste list)
  {
    this.fix_wert_typ = list.fix_wert_typ;
    this.werte = list.werte;
  }

  pure nothrow
  size_t länge() const
  {
    return this.werte.length;
  }

  void anfügen(Wert wert)
  {
    if (!ist_valide_mitglied_typ(wert))
    {
      throw new Liste_TypenFehler(this.fix_wert_typ[0], wert.typ);
    }

    if (this.fix_wert_typ.length == 0)
    {
      this.werte ~= wert;
      return;
    }
  }

  private
  bool ist_valide_mitglied_typ(const Wert wert)
  {
    WertTyp[] andere_typ = [];

    if (wert.typ == WertTyp.LISTE)
    {
      Liste andere_liste = *cast(Liste*) wert.wert;
      andere_typ = WertTyp.LISTE ~ andere_liste.fix_wert_typ;
    }
    else
      andere_typ ~= wert.typ;

    return andere_typ == this.fix_wert_typ;
  }

  void typisiere(WertTyp[] liste)
  {
    this.fix_wert_typ = liste;

    if (this.werte.length == 0)
      return;

    if (this.fix_wert_typ.length == 0)
      return;

    foreach (Wert wert; werte)
    {
      if (!ist_valide_mitglied_typ(wert))
        throw new Fehler("Kann nicht typisiert werden zu: ");
    }
  }

  Wert element_bei_index(size_t index)
  {
    if (index >= werte.length)
    {
      throw new Fehler("Out of Bounds");
    }

    return Wert(werte[index]);
  }

  void setzte_element_bei_index(size_t index, Wert neuer_wert)
  {
    if (index >= werte.length)
    {
      throw new Fehler("Out of Bounds");
    }

    if (this.fix_wert_typ.length != 0 && !ist_valide_mitglied_typ(neuer_wert))
    {
      throw new Liste_TypenFehler(this.fix_wert_typ[0], neuer_wert.typ);
    }

    werte[index] = neuer_wert;
  }

  string toString() const
  {
    string str = "[";

    bool first_run = true;

    foreach (const Wert wert; this.werte)
    {
      if (!first_run)
        str ~= ", ";

      str ~= als_schön_string(wert);

      first_run = false;
    }

    str ~= "]";

    return str;
  }

  //MARK: opCmp
  int opCmp(const Liste other) const
  {
    if (this.länge != other.länge)
    {
      return this.länge > other.länge ? 1 : -1;
    }

    for (size_t i = 0; i < this.länge; i++)
    {
      if (this.werte[i] != other.werte[i]) //return this.werte[i] > other.werte[i] ? 1 : -1;
        return -1; //TODO: Fix on merge
    }

    return 0;
  }

  bool opEquals(const Liste other) const
  {
    return this.opCmp(other) == 0;
  }

  //MARK: opBinary
  Liste opBinary(string op, R)(const R other)
  {
    static if (is(R == Liste))
    {
      switch (op)
      {
      case "+":
        return addiere(other);

      default:
        debug
        {
          import std.stdio : write, writeln;

          write("FEHLER: Der Operator kann nicht an Nzahl ausgeführt werden: ");
          writeln(op);
        }
        throw new Fehler("Dieser Operator ist nicht toll für Listen: " ~ op);
      }
    }
    else
      throw new Parse_Fehler("Typen_Fehler, (Listen)");
  }

  Liste addiere(const Liste other)
  {
    Liste neu = Liste(this.fix_wert_typ, []);
    neu.werte.reserve(this.länge + other.länge);

    foreach (Wert wert; this.werte)
    {
      neu.anfügen(wert);
    }

    foreach (Wert wert; werte)
    {
      neu.anfügen(wert);
    }

    return neu;
  }
}
