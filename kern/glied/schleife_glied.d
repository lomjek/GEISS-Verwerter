module glied.schleife_glied;

import glied.block_glied : BlockGlied;
import glied.glied : Glied;
import glied.signal_glied : Signal, SignalTyp;
import glied.variablen_glied : Erstelle_Variable_Glied;

import wert;
import zahl;
import fehler;
import variablen.speicher;
import liste;

import std.stdio : write, writeln;
import std.conv : to;

// @ {} [] # \ || != ~

//MARK: SOLANGE
class Solange_BlockGlied : BlockGlied
{
  Glied bedingung;

  override public void schreibe_baum()
  {
    write("[SOLANGE ");
    bedingung.schreibe_baum();
    write("]{");
    schreibe_glied_liste(this.aktionen);
    write("}");
  }

  private bool erfüllt(uint bereich)
  {
    Wert wert_bedingung = bedingung.verwerte(bereich);
    return wert_bedingung.ist_wahr;
  }

  override public Wert verwerte(uint bereich)
  {
    try
    {
      while (erfüllt(bereich))
      {
        verwerte_glieder_liste(bereich, aktionen);
      }
    }
    catch (Signal s)
    {
      if (s.signal_typ != SignalTyp.BEENDE_SCHLEIFE)
        throw s;
    }
    return Wert(WertTyp.INVALID, null);
  }

  override public bool ist_vollständig()
  {
    return (bedingung !is null);
  }

  override string toString() const
  {
    return "G(SOLANGE | " ~ aktionen.length.to!string ~ ")";
  }
}

//MARK: WIEDERHOLE
class Wiederhole_BlockGlied : BlockGlied
{
  Glied wiederholungen;

  private Nzahl gebrauchte_wiederholungen;
  private Nzahl gemachte_wiederholungen = Nzahl();

  override public void schreibe_baum()
  {
    write("[WIEDERHOLE ");
    wiederholungen.schreibe_baum();
    write("]{");
    schreibe_glied_liste(this.aktionen);
    write("}");
  }

  override public Wert verwerte(uint bereich)
  {
    Wert wdh = wiederholungen.verwerte(bereich);

    if (wdh.typ == WertTyp.NATÜRLICHE_ZAHL)
    {
      gebrauchte_wiederholungen = Nzahl(*cast(Nzahl*) wdh.wert);
    }
    else if (wdh.typ == WertTyp.GANZE_ZAHL)
    {
      gebrauchte_wiederholungen = Nzahl((*cast(Gzahl*) wdh.wert).grösse);
    }
    else if (wdh.typ == WertTyp.ZAHL)
    {
      gebrauchte_wiederholungen = Nzahl((*cast(Zahl*) wdh.wert).grösse);
    }

    try
    {
      while (gebrauchte_wiederholungen > gemachte_wiederholungen)
      {
        gemachte_wiederholungen = gemachte_wiederholungen + Nzahl([1]);

        verwerte_glieder_liste(bereich, aktionen);
      }
    }
    catch (Signal s)
    {
      if (s.signal_typ != SignalTyp.BEENDE_SCHLEIFE)
        throw s;
    }

    return Wert(WertTyp.INVALID, null);
  }

  override public bool ist_vollständig()
  {
    return (wiederholungen !is null);
  }

  override string toString() const
  {
    return "G(WIEDERHOLE | " ~ aktionen.length.to!string ~ ")";
  }
}

//MARK: PRO VON
class Pro_Von_BlockGlied : BlockGlied
{
  Erstelle_Variable_Glied variable;
  Glied liste;

  override public void schreibe_baum()
  {
    write("[PRO ");
    if (variable !is null)
      variable.schreibe_baum();
    write(" VON ");
    if (liste !is null)
      liste.schreibe_baum();
    write("]{");
    schreibe_glied_liste(this.aktionen);
    write("}");
  }

  override public Wert verwerte(uint bereich)
  {
    dstring var_name = variable.var_name;
    variable.verwerte(bereich); // TODO: Es wird in Zukunft ein neues System brauchen, falls der variablenname schon besetzt ist.
    Wert list = liste.verwerte(bereich);

    if (list.typ != WertTyp.LISTE)
      throw new Fehler("Man kann nur durch Listen iterieren.");

    Liste l = *list.liste;

    foreach (Wert wert; l.werte)
    {
      setze_variable(bereich, var_name, new Wert(wert));

      verwerte_glieder_liste(bereich, aktionen);
    }

    return Wert(WertTyp.INVALID, null);
  }

  override public bool ist_vollständig()
  {
    return (variable !is null) && (liste !is null);
  }

  override string toString() const
  {
    return "G(PRO_VON | " ~ aktionen.length.to!string ~ ")";
  }
}
