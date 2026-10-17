module glied.liste_glied;

import variablen.wert;
import variablen.speicher;

import liste;
import zahl;
import fehler;

import glied.glied : Glied;
import glied.wert_glied : Wert_Glied;
import glied.variablen_glied : Lese_Variable_Glied;

import std.stdio : write;
import std.conv : to;

//MARK: ListeWert_Glied
class ListeWert_Glied : Wert_Glied
{
  Glied[] werte;

  public size_t länge()
  {
    return werte.length;
  }

  override public Wert verwerte(uint bereich)
  {
    Wert[] liste;

    foreach (Glied glied; this.werte)
    {
      liste ~= glied.verwerte(bereich);
    }

    return Wert(WertTyp.LISTE, new Liste([], liste));
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public void schreibe_baum()
  {
    write("[LISTE]{");

    bool first_run = true;
    foreach (Glied glied; this.werte)
    {
      if (!first_run)
        write(", ");

      glied.schreibe_baum;

      first_run = false;
    }
    write("}");
  }

  override public string toString() const
  {
    string str = "G(LISTE | [";

    bool first_run = true;

    foreach (glied; werte)
    {
      if (!first_run)
        str ~= ", ";

      str ~= to!string(glied);

      first_run = false;
    }

    str ~= "]";
    return str;
  }

  this(Glied[] init_liste)
  {
    this.werte = init_liste;
  }
}

class LiesListeElement_Glied : Glied
{
  Glied index;
  Glied liste;

  override public Wert verwerte(uint bereich)
  {
    Wert tindex = index.verwerte(bereich);

    Nzahl pindex;

    if (tindex.wert is null)
      throw new Fehler("Illegal State");

    //Für jetzt werden Brüche einfach ignoriert.
    if (tindex.typ == WertTyp.ZAHL &&
      (*cast(Zahl*) tindex.wert) >= Zahl(Nzahl([0])))
    {
      pindex = Nzahl((*cast(Zahl*) tindex.wert).grösse);
    }
    else if (tindex.typ == WertTyp.GANZE_ZAHL &&
      (*cast(Gzahl*) tindex.wert) >= Gzahl(Nzahl([0])))
    {
      pindex = Nzahl((*cast(Gzahl*) tindex.wert).grösse);
    }
    else if (tindex.typ == WertTyp.NATÜRLICHE_ZAHL)
    {
      pindex = Nzahl(*cast(Nzahl*) tindex.wert);
    }
    else
      throw new Fehler("Dieser Index ist nicht erreichbar...");

    size_t array_index = pindex.als_size_t(false); //TODO: Vielleicht wäre es toll, wenn wir den Benutzter warnen, wenn er das macht...

    Wert tliste = liste.verwerte(bereich);

    if (tliste.typ != WertTyp.LISTE)
      throw new Fehler("Man kann nicht anderes als Listen Indexen");

    if (tliste.wert is null)
      throw new Fehler("Illegal State");

    Liste pliste = *cast(Liste*) tliste.wert;

    return pliste.element_bei_index(array_index);
  }

  override public pure nothrow @safe @nogc
  bool ist_vollständig()
  {
    return index !is null && liste !is null;
  }

  override public
  void schreibe_baum()
  {
    write("[LIES_ELEMENT ");
    index.schreibe_baum;
    write("]{");
    liste.schreibe_baum;
    write("}");
  }

  public pure nothrow @safe @nogc
  this(Glied nindex, Glied lvg)
  {
    liste = lvg;
    index = nindex;
  }
}

class SetzeListeElement_Glied : Glied
{
  Glied index;
  Glied liste;
  Glied neuer_wert;

  override public Wert verwerte(uint bereich)
  {
    Wert tindex = index.verwerte(bereich);

    Nzahl pindex;

    if (tindex.wert is null)
      throw new Fehler("Illegal State");

    //Für jetzt werden Brüche einfach ignoriert.
    if (tindex.typ == WertTyp.ZAHL &&
      (*cast(Zahl*) tindex.wert) >= Zahl(Nzahl([0])))
    {
      pindex = Nzahl((*cast(Zahl*) tindex.wert).grösse);
    }
    else if (tindex.typ == WertTyp.GANZE_ZAHL &&
      (*cast(Gzahl*) tindex.wert) >= Gzahl(Nzahl([0])))
    {
      pindex = Nzahl((*cast(Gzahl*) tindex.wert).grösse);
    }
    else if (tindex.typ == WertTyp.NATÜRLICHE_ZAHL)
    {
      pindex = Nzahl(*cast(Nzahl*) tindex.wert);
    }
    else
      throw new Fehler("Dieser Index ist nicht erreichbar...");

    size_t array_index = pindex.als_size_t(false); //TODO: Vielleicht wäre es toll, wenn wir den Benutzter warnen, wenn er das macht...

    Wert tliste = liste.verwerte(bereich);

    if (tliste.typ != WertTyp.LISTE)
      throw new Fehler("Man kann nicht anderes als Listen Indexen");

    if (tliste.wert is null)
      throw new Fehler("Illegal State");

    Liste pliste = *cast(Liste*) tliste.wert;

    pliste.setzte_element_bei_index(array_index, neuer_wert.verwerte(bereich));

    return Wert();
  }

  override public pure nothrow @safe @nogc
  bool ist_vollständig()
  {
    return index !is null && liste !is null && neuer_wert !is null;
  }

  override public
  void schreibe_baum()
  {
    write("[SETZTE_ELEMENT ");
    index.schreibe_baum;
    write("]{");
    liste.schreibe_baum;
    write(" / ");
    neuer_wert.schreibe_baum;
    write("}");
  }

  public pure nothrow @safe @nogc
  this(Glied nindex, Glied lvg, Glied neuer_nwert)
  {
    liste = lvg;
    index = nindex;
    neuer_wert = neuer_nwert;
  }
}
