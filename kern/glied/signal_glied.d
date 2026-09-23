module glied.signal_glied;

import glied.glied;
import variablen.wert;

import std.stdio : write, writeln;

// @ {} [] # \ || != ~

abstract class Signal : Exception
{
  this(string msg, string file = __FILE__, size_t linie = __LINE__, Throwable next = null) pure nothrow @safe
  {
    super("Signal: " ~ msg, file, linie, next);
  }
}

class Beende_Funktion_Signal : Signal
{
  this(string file = __FILE__, size_t linie = __LINE__, Throwable next = null) pure nothrow @safe
  {
    super("Beende_Funktion", file, linie, next);
  }
}

class Beende_Programm_Signal : Signal
{
  this(string file = __FILE__, size_t linie = __LINE__, Throwable next = null) pure nothrow @safe
  {
    super("Beende_Programm", file, linie, next);
  }
}

class Beende_Funktion_Glied : Glied
{
  override public Wert verwerte(uint bereich)
  {
    throw new Beende_Funktion_Signal();
  }

  override public void schreibe_baum(){
    write("{BEENDE_FUNKTION}");
  }

  override public bool ist_vollständig(){
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
    throw new Beende_Programm_Signal();
  }

  override public void schreibe_baum(){
    write("{BEENDE_PROGRAMM}");
  }

  override public bool ist_vollständig(){
    return true;
  }

  override public string toString() const
  {
    return "G(BEENDE_PROGRAMM)";
  }
}
