module liste;

import fehler;
import ext.prints;
import variablen.wert;

import std.conv : to;

// @ {} [] # \ || != ~

struct Liste
{
  WertTyp[] fix_wert_typ;
  Wert[] werte;

  this(WertTyp[] fixer_wert_typ, Wert[] werte)
  {
    this.fix_wert_typ = fixer_wert_typ;
    this.werte = werte;
  }

  this(Liste list)
  {
    this.fix_wert_typ = list.fix_wert_typ;
    this.werte = list.werte;
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

    str ~= fix_wert_typ.to!string;

    return str;
  }
}
