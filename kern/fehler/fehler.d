module fehler.fehler;

import interpreter : repl_mode, file_name;
import operatoren;
import wert;
import glied;

import std.conv : to;
import std.array : join;

// @ {} [] # \ || != ~

class Fehler : Exception
{
  this(string msg, size_t line = __LINE__)
  {
    if (repl_mode)
    {
      super(msg.to!string, "REPL", 1, null);
    }
    else
    {
      super(msg.to!string, file_name.to!string, line, null);
    }
  }
}

//MARK: Variablen
abstract class VariablenFehler : Fehler
{
  this(string msg, size_t line = __LINE__)
  {
    super(msg, line);
  }
}

class Variable_Nicht_Existent_Fehler : VariablenFehler
{
  this(dstring variable_name, dstring[] bekannte_variablen, size_t linie = __LINE__)
  {
    string msg = "Variable '" ~ variable_name.to!string ~ "' gibt es nicht!\nBekannte Variablen: " ~
      (
        join(
          bekannte_variablen, ", ")).to!string;
    super(msg, linie); //Todo: Das Line getue fixen
  }
}

class Bereich_Nicht_Existent_Fehler : Fehler
{
  this(uint bereich_num, size_t linie = __LINE__)
  {
    string msg = "Bereich für Variablen mit der Nummer " ~ bereich_num.to!string ~ " existiert nicht.";
    super(msg, linie);
  }
}

class Variable_Schon_Existent_Fehler : VariablenFehler
{
  this(dstring variable_name)
  {
    string msg = "Variable '" ~ variable_name.to!string ~ "' gibt es schon!";
    super(msg);
  }
}

class Variable_Assign_Typ_Error : VariablenFehler
{
  this(dstring variable_name, WertTyp variable_typ, WertTyp wert_typ)
  {
    string msg = "Variable '" ~ variable_name.to!string ~ "' mit dem Typ " ~ variable_typ.to!string ~
      " kann nicht Wert von Typ " ~ wert_typ.to!string ~ " enthalten";
    super(msg);
  }
}

//MARK: Typenfehler
class Operation_TypenFehler : Fehler
{
  this(OperatorenTyp op_typ, WertTyp w1_typ, WertTyp w2_typ, size_t linie = __LINE__)
  {
    string message = "Die Operation " ~ op_typ.to!string ~ " kann nicht mit den Typen " ~ w1_typ.to!string ~ " und "
      ~ w2_typ.to!string ~ "durchegführt werden.";
    super(message, linie);
  }
}

class Liste_TypenFehler : Fehler
{
  this(WertTyp liste_typ, WertTyp w_typ)
  {
    string message = "Die fixe liste voller "
      ~ liste_typ.to!string ~ " kann nicht " ~ w_typ.to!string ~ " enthalten";
    super(message);
  }
}
