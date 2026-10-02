module liste;

import fehler;
import ext.prints;
import variablen.wert;

// @ {} [] # \ || != ~

struct Liste
{
  bool variabel; // Kann die Liste unterschiedliche Typen enthalten?
  WertTyp fix_wert_typ; // Falls ja, welcher ist dieser fixe Typ?
  Wert[] werte;

  this(bool variabel, WertTyp fixer_wert_typ, Wert[] werte)
  {
    this.variabel = variabel;
    this.fix_wert_typ = fixer_wert_typ;
    this.werte = werte;
  }

  this(Liste list)
  {
    this.variabel = list.variabel;
    this.fix_wert_typ = list.fix_wert_typ;
    this.werte = list.werte;
  }

  void anfügen(Wert wert, bool copy_wert = true)
  {
    if (this.variabel)
    {
      this.werte ~= wert;
    }

    if (wert.typ != this.fix_wert_typ)
    {
      throw new Liste_TypenFehler(this.fix_wert_typ, wert.typ);
    }
  }

  Wert element_bei_index(size_t index)
  {
    if (index >= werte.length)
    {
      throw new Fehler("Out of Bounds");
    }

    return werte[index];
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
}

