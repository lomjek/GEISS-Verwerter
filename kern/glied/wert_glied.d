module glied.wert_glied;

import std.stdio : write;
import std.conv : to;

import wert;
import zahl;
import liste;
import glied.glied;

import ext.prints;

// @ {} [] # \ || != ~

class Wert_Glied : Glied
{
  Wert wert;

  override public Wert verwerte(uint bereich)
  {
    return wert;
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public void schreibe_baum()
  {
    schreibe_schön_wert(wert);
  }

  override public string toString() const
  {
    return "G(WERT | " ~ wert.als_string(Str_conv_typ.INTERNAL) ~ ")";
  }

  this(Wert neuer_wert)
  {
    wert = neuer_wert;
  }

  this()
  {
    this.wert = Wert(WertTyp.INVALID, null);
  }
}

class WT_Glied : Glied
{
  public WertTyp vt;
  public WT_Glied unter_wt;

  override public Wert verwerte(uint bereich)
  {
    return Wert(WertTyp.INVALID, null);
  }

  override public void schreibe_baum()
  {
    write(vt.to!string);
  }

  public pure nothrow @safe
  WertTyp[] unroll()
  {
    if (unter_wt !is null)
      return this.vt ~ unter_wt.unroll();

    return [this.vt];
  }

  override public bool ist_vollständig()
  {
    return false;
  }

  this(WertTyp vta)
  {
    this.vt = vta;
  }

  override string toString() const
  {
    if (unter_wt is null)
      return "G(WertTyp | " ~ this.vt.to!string ~ ")";

    else
      return "G(WertTyp | " ~ this.vt.to!string ~ ">" ~ unter_wt.toString() ~ ")";
  }
}
