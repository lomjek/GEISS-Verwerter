module liste;

import fehler;
import ext.prints;
import wert;

// @ {} [] # \ || != ~

struct Liste
{
  bool variabel; // Kann die Liste unterschiedliche Typen enthalten?
  WertTyp fix_wert_typ; // Falls ja, welcher ist dieser fixe Typ?
  Wert*[] werte;

  this(bool variabel, WertTyp fixer_wert_typ, Wert*[] werte)
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

  int opCmp(const Liste other) const
  {
    return -1; //TODO: IMPLEMENT branch => listen  
  }

  Liste opBinary(string op, T)(T other)
  {
    static if (!is(T == Liste))
      throw new Fehler("Falscher Typ");

    return Liste();
  }
}

void anfügen(Liste* liste, Wert* wert)
{
  if (liste.variabel)
  {
    liste.werte ~= wert;
  }

  if (wert.typ != liste.fix_wert_typ)
  {
    throw new Liste_TypenFehler(liste.fix_wert_typ, wert.typ);
  }
}

string als_string(Liste li)
{
  string str = "[";

  bool first_run = true;

  foreach (Wert* wert; li.werte)
  {
    if (!first_run)
      str ~= ", ";

    str ~= als_schön_string(*wert);

    first_run = false;
  }

  str ~= "]";

  return str;
}
