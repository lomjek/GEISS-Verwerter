module glied.signal_glied;

import glied.glied;
import wert;

import std.stdio : write, writeln;

// @ {} [] # \ || != ~

enum SignalTyp
{
  UNDEFINED,
  BEENDE_PROGRAMM,
  BEENDE_FUNKTION,
  BEENDE_SCHLEIFE,
}

private immutable
string[SignalTyp] signal_typ_names =
  [
    SignalTyp.UNDEFINED: "",
    SignalTyp.BEENDE_PROGRAMM: "beende programm",
    SignalTyp.BEENDE_FUNKTION: "beende funktion",
    SignalTyp.BEENDE_SCHLEIFE: "beende schleife",
  ];

class Signal : Exception
{
  SignalTyp signal_typ;

  public pure nothrow @safe
  this(SignalTyp signal_typ, string msg = "", string file = __FILE__, size_t linie = __LINE__, Throwable next = null)
  {
    this.signal_typ = signal_typ;
    super("Signal: " ~ signal_typ_names[signal_typ] ~ " " ~ msg, file, linie, next);
  }
}

class Beende_Funktion_Glied : Glied
{
  override public Wert verwerte(uint bereich)
  {
    throw new Signal(SignalTyp.BEENDE_FUNKTION);
  }

  override public void schreibe_baum()
  {
    write("{BEENDE_FUNKTION}");
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public string toString() const
  {
    return "G(BEENDE_FUNKTION)";
  }
}

class Beende_Programm_Glied : Glied
{
  override public Wert verwerte(uint bereich)
  {
    throw new Signal(SignalTyp.BEENDE_PROGRAMM);
  }

  override public void schreibe_baum()
  {
    write("{BEENDE_PROGRAMM}");
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public string toString() const
  {
    return "G(BEENDE_PROGRAMM)";
  }
}

class Beende_Schleife_Glied : Glied
{
  override public Wert verwerte(uint bereich)
  {
    throw new Signal(SignalTyp.BEENDE_SCHLEIFE);
  }

  override public void schreibe_baum()
  {
    write("{BEENDE_SCHLEIFE}");
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public string toString() const
  {
    return "G(BEENDE_SCHLEIFE)";
  }
}
