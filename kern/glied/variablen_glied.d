module glied.variablen_glied;

import wert;
import variablen.speicher;
import variablen.variable;

import zahl;
import fehler;
import liste;
import glied.glied;
import glied.wert_glied : WT_Glied;

import std.stdio : write;
import std.conv : to;

// @ {} [] # \ || != ~

class Erstelle_Variable_Glied : Glied
{
  WT_Glied wert_typ;
  private VariablenTyp var_typ;
  public dstring var_name;

  override public Wert verwerte(uint bereich)
  {
    if (!ist_vollständig())
      throw new Fehler("Glied muss vollständig sein, bevor man es ausführt.");

    Wert* wert;
    if (wert_typ.vt != WertTyp.LISTE)
      wert = new Wert(wert_typ.vt, null);

    else
    {
      wert = new Wert(WertTyp.LISTE, new Liste(wert_typ.unroll()[1 .. $], []));
    }
    erstelle_variable(bereich, var_name, var_typ, wert);
    return Wert(WertTyp.INVALID, null);
  }

  override public void schreibe_baum()
  {
    write("[ERSTELLE_VARIABLE]{" ~ var_name ~ "}");
  }

  override public bool ist_vollständig()
  {
    return (var_name.length != 0) && (var_typ != VariablenTyp.INVALID) &&
      (wert_typ.vt != WertTyp.FUNKTION);
  }

  this(dstring var_name, WT_Glied constructor)
  {
    this.var_name = var_name;
    if (constructor.vt == WertTyp.INVALID)
    {
      this.var_typ = VariablenTyp.VARIABEL;
    }
    else
    {
      this.var_typ = VariablenTyp.FIX;
    }
    wert_typ = constructor;
  }

  this(dstring var_name, WertTyp constructor)
  {
    this(var_name, new WT_Glied(constructor));
  }

  override string toString() const
  {
    return "G(MACHE_VAR | " ~ var_name.to!string ~ ")";
  }
}

class Setze_Variable_Glied : Glied
{
  dstring var_name;
  Glied assign_wert;

  override public Wert verwerte(uint bereich)
  {
    Wert result = assign_wert.verwerte(bereich);
    Wert* pointer = new Wert(result.typ, result.wert);
    setze_variable(bereich, var_name, pointer);
    return Wert(WertTyp.INVALID, null);
  }

  override public void schreibe_baum()
  {
    write("[SETZE_VARIABLE " ~ var_name ~ "]{");
    assign_wert.schreibe_baum;
    write("}");
  }

  override public bool ist_vollständig()
  {
    return (var_name != "" && assign_wert !is null);
  }

  override string toString() const
  {
    return "G(SETZE_VAR | " ~ var_name.to!string ~ ")";
  }
}

class Lese_Variable_Glied : Glied
{
  dstring var_name;

  override public Wert verwerte(uint bereich)
  {
    Variable var;
    try
    {
      var = lies_variable(bereich, var_name);
    }
    catch (Variable_Nicht_Existent_Fehler)
    {
      var = lies_variable(0, var_name);
    }

    Wert wert = *cast(Wert*) var.wert;
    return wert;
  }

  override public void schreibe_baum()
  {
    write("{" ~ var_name ~ "}");
  }

  override public bool ist_vollständig()
  {
    return var_name != "";
  }

  this(dstring namen)
  {
    this.var_name = namen;
  }

  override string toString() const
  {
    return "G(LESE_VAR | " ~ var_name.to!string ~ ")";
  }
}
