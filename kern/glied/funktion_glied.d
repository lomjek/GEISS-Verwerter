module glied.funktion_glied;

import glied.glied;
import glied.variablen_glied : Erstelle_Variable_Glied;
import glied.block_glied;

import variablen.wert;
import variablen.speicher;
import variablen.variable;

import ext.prints;

import fehler;
import zahl;
import text;

import std.stdio : writeln, write;
import std.conv : to;

// @ {} [] # \ || != ~

//MARK: F...Abrufen_Glied
class Funktion_Abrufen_Glied : Glied
{
  Glied[] argumente;
  dstring identifier;

  override public void schreibe_baum()
  {
    write("[FUNKTION]{");
    write(identifier);
    write(", ");
    argumente.to!string;
    write("}");
  }

  override public Wert verwerte(uint bereich)
  {
    uint neuer_bereich = initialisiere_bereich(identifier);
    Variable var;
    try
    {
      var = lies_variable(bereich, identifier);
    }
    catch (Variable_Nicht_Existent_Fehler)
    {
      var = lies_variable(0, identifier);
    }

    if (var.var_typ != VariablenTyp.FUNKTION)
    {
      throw new Fehler("Variable " ~ var.to!string ~ " ist keine Funktion!");
    }

    Funktion_Glied fg = cast(Funktion_Glied) var.wert;

    //ARGUMENTE
    dstring[] arg_namen;

    foreach (Erstelle_Variable_Glied evg; fg.parameter)
    {
      evg.verwerte(neuer_bereich);
      arg_namen ~= evg.var_name;
    }

    if (argumente.length != arg_namen.length)
    {
      throw new Fehler("Die Anzahl Argumenten ist nicht richtg: Wollte " ~ arg_namen.length.to!string ~ ", habe aber " ~ argumente
          .length.to!string ~ ".");
    }

    for (ulong i = 0; i < argumente.length; i++)
    {
      Wert* argument = new Wert(argumente[i].verwerte(bereich));
      setze_variable(neuer_bereich, arg_namen[i], argument);
    }

    //RETURNS (für jetzt nur eins)
    dstring[] ret_namen;

    foreach(Erstelle_Variable_Glied evg; fg.return_values)
    {
      evg.verwerte(neuer_bereich);
      ret_namen ~= evg.var_name;
    }

    fg.verwerte(neuer_bereich);

    Wert resultat;
    if (ret_namen.length == 1)
    {
      resultat = *(cast(Wert*) lies_variable(neuer_bereich, ret_namen[0]).wert); // Muss geändert werden.
    }
    else if (ret_namen.length == 0) 
    {
      resultat  = Wert(WertTyp.INVALID, null);
    }
    else{
      debug writeln("Mehrere argumente noch nicht implementiert");
    }

    lösche_bereich(neuer_bereich);

    return resultat;
  }

  override public bool ist_vollständig()
  {
    return true;
  }

  override public
    string toString() const
    {
      return "G(FUNKTION_ABRUFEN | " ~ identifier.to!string ~ ")";
    }

  this(dstring funk_name, Glied[] argumente)
  {
    identifier = funk_name;
    this.argumente = argumente;
  }
}

//region Funktion_Glied
class Funktion_Glied : Glied
{
  Erstelle_Variable_Glied[] parameter;
  Erstelle_Variable_Glied[] return_values;
  BlockGlied körper;

  override public void schreibe_baum()
  {
    write("F");
    körper.schreibe_baum();
  }

  override public Wert verwerte(uint bereich)
  {
    if (körper !is null)
      körper.verwerte(bereich); //Hier muss wahrscheinlich noch das ganze mit den Argumenten gehandhabt werden. 

    else
      throw new Fehler("Körper ist nicht gültig => Sollte nie dahin kommen...");

    return Wert();
  }

  override public bool ist_vollständig()
  {
    return körper !is null;
  }

  this(Erstelle_Variable_Glied[] parameter, Erstelle_Variable_Glied[] return_values, BlockGlied körper)
  {
    this.parameter = parameter;
    this.return_values = return_values;
    this.körper = körper;
  }
}

enum MethodenTyp
{
  PRINT,
  ALS_TEXT,
  ALS_ZAHL,
}

class EingebauteFunktion_Glied : Funktion_Glied
{
  MethodenTyp typ;

  override public Wert verwerte(uint bereich)
  {
    switch (typ)
    {
      case MethodenTyp.PRINT:
        Wert text = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
        schreibe_schön_wert(text);
        writeln;
        goto default;

      case MethodenTyp.ALS_TEXT:
        Wert zahl = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
        Zahl z;
        if (zahl.typ == WertTyp.ZAHL)
          z = *cast(Zahl*) zahl.wert;
        else if (zahl.typ == WertTyp.GANZE_ZAHL)
          z = Zahl(*cast(GanzeZahl*) zahl.wert);
        else if (zahl.typ == WertTyp.NATÜRLICHE_ZAHL)
          z = Zahl(*cast(NatürlicheZahl*) zahl.wert);
        else
          throw new Fehler("Funktion als_text benötigt eine Zahl als Eingabe");

        string str = z.als_string;

        setze_variable(bereich, "ausgabe", new Wert(WertTyp.TEXT, new Text(str)));
        goto default;

      default:
        return Wert(WertTyp.INVALID, null);
    }
  }

  override public bool ist_vollständig()
  {
    return parameter !is null;
  }

  override public void schreibe_baum()
  {
    write(typ.to!string);
  }

  override string toString() const
  {
    return "G(" ~ typ.to!string ~ ")";
  }

  this(MethodenTyp funktion)
  {
    this.typ = funktion;

    Erstelle_Variable_Glied[] parameter;
    Erstelle_Variable_Glied[] return_values;

    if (typ == MethodenTyp.PRINT)
    {
      Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.TEXT);
      parameter ~= evg;
    }
    else if (typ == MethodenTyp.ALS_TEXT)
    {
      // Parameter
      Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.ZAHL);
      parameter ~= evg;

      // Return Value
      Erstelle_Variable_Glied rvg = new Erstelle_Variable_Glied("ausgabe", WertTyp.TEXT);
      return_values ~= rvg;
    }

    super(parameter, return_values, new BlockGlied());
  }
}
//endregion
//regeion FunktionErstellen_Glied
class FunktionErstellen_Glied : Glied // TODO:Muss noch Parameter und returns machen 
{
  Funktion_Glied körper;
  dstring var_name;
  Glied[] parameter;

  override public Wert verwerte(uint bereich)
  {
    Wert* wert = new Wert(WertTyp.FUNKTION, cast(void*) körper);
    erstelle_variable(bereich, var_name, VariablenTyp.FUNKTION, wert);
    return Wert();
  }

  override public void schreibe_baum()
  {
    write("[ERSTELLE_FUNKTION]{" ~ var_name ~ "}");
  }

  override public bool ist_vollständig()
  {
    return (körper !is null) && (var_name.length != 0);
  }

  override public
    string toString() const
    {
      return "G(ERSTELLE_FUNKTION | " ~ var_name.to!string ~ ")";
    }

  this(BlockGlied körper, dstring variable)
  {
    this.körper = new Funktion_Glied([], [], körper);
    this.var_name = variable;
  }

  this(BlockGlied körper, dstring variable, Erstelle_Variable_Glied[] parameter)
  {
    this.körper = new Funktion_Glied(parameter, [], körper);
    this.var_name = variable;
  }
}
//endregion
