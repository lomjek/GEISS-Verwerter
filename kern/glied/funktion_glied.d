module glied.funktion_glied;

import glied.glied;
import glied.variablen_glied : Erstelle_Variable_Glied;
import glied.block_glied;
import glied.signal_glied : Signal, SignalTyp;

import wert;
import variablen.speicher;
import variablen.variable;

import ext.prints;
import ext.algorithm : random_zahl;

import fehler;
import zahl;
import liste;
import text;

import std.stdio : writeln, write, readln;
import std.conv : to;

// @ {} [] # \ || != ~

//MARK: F...Abrufen_Glied
class Funktion_Abrufen_Glied : Glied
{
  Glied[] argumente;
  dstring identifier;

  override public void schreibe_baum()
  {
    write("[FUNKTION ");
    write(identifier);
    write("]{");
    write(argumente.to!string);
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
      throw new Fehler("Die Anzahl Argumenten ist nicht richtg für '" ~ identifier.to!string ~ "'': Wollte " ~
          arg_namen.length.to!string ~ ", habe aber " ~ argumente.length.to!string ~ ".");
    }

    for (ulong i = 0; i < argumente.length; i++)
    {
      Wert* argument = new Wert(argumente[i].verwerte(bereich));
      setze_variable(neuer_bereich, arg_namen[i], argument);
    }

    //RETURNS (für jetzt nur eins)
    dstring[] ret_namen;

    foreach (Erstelle_Variable_Glied evg; fg.return_values)
    {
      evg.verwerte(neuer_bereich);
      ret_namen ~= evg.var_name;
    }

    try
    {
      fg.verwerte(neuer_bereich);
    }
    catch (Signal s)
    {
      if (s.signal_typ != SignalTyp.BEENDE_FUNKTION)
        throw s;
    }

    Wert resultat;
    if (ret_namen.length == 1)
    {
      resultat = *(cast(Wert*) lies_variable(neuer_bereich, ret_namen[0]).wert); // Muss geändert werden.
    }
    else if (ret_namen.length == 0)
    {
      resultat = Wert(WertTyp.INVALID, null);
    }
    else
    {
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

enum MethodenTyp : ubyte
{
  PRINT,
  ALS_TEXT,
  ALS_ZAHL,
  EINGABE,
  ZUFÄLLIGE_ZAHL,
  INDIZES,
  LÄNGE,
}

class EingebauteFunktion_Glied : Funktion_Glied
{
  MethodenTyp typ;

  override public Wert verwerte(uint bereich)
  {
    final switch (typ)
    {
    case MethodenTyp.PRINT:
      Wert text = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
      writeln(text.als_string(Str_conv_typ.AUSGABE));
      return Wert();

    case MethodenTyp.ALS_TEXT:
      Wert zahl = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
      Zahl z;
      if (zahl.typ == WertTyp.ZAHL)
        z = *cast(Zahl*) zahl.wert;
      else if (zahl.typ == WertTyp.GANZE_ZAHL)
        z = Zahl(*cast(Gzahl*) zahl.wert);
      else if (zahl.typ == WertTyp.NATÜRLICHE_ZAHL)
        z = Zahl(*cast(Nzahl*) zahl.wert);
      else
        throw new Fehler("Funktion als_text benötigt eine Zahl als Eingabe");

      string str = z.als_string;

      setze_variable(bereich, "ausgabe", new Wert(WertTyp.TEXT, new Text(str)));
      return Wert();

    case MethodenTyp.ALS_ZAHL:
      Wert text = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
      if (text.typ != WertTyp.TEXT)
        throw new Fehler("Ich kann nicht anderes als Text in eine Zahl umwandeln.");

      string str = (*cast(Text*) text.wert).str;
      Zahl z = als_zahl(str.to!dstring);

      setze_variable(bereich, "ausgabe", new Wert(WertTyp.ZAHL, new Zahl(z)));
      return Wert();

    case MethodenTyp.EINGABE:
      Wert text = *cast(Wert*) lies_variable(bereich, "aufforderung").wert;
      write(text.als_string(Str_conv_typ.AUSGABE));

      string eingabe = readln();
      eingabe = eingabe[0 .. eingabe.length - 1];
      setze_variable(bereich, "ausgabe", new Wert(WertTyp.TEXT, new Text(eingabe)));
      return Wert();

    case MethodenTyp.ZUFÄLLIGE_ZAHL:
      Wert ul = *cast(Wert*) lies_variable(bereich, "unteres_limit").wert;
      Wert ol = *cast(Wert*) lies_variable(bereich, "oberes_limit").wert;

      Gzahl ulimit;
      Gzahl olimit;

      if (ul.typ == WertTyp.GANZE_ZAHL)
        ulimit = Gzahl(*cast(Gzahl*) ul.wert);

      else if (ul.typ == WertTyp.NATÜRLICHE_ZAHL)
        ulimit = Gzahl(*cast(Nzahl*) ul.wert);

      else if (ul.typ == WertTyp.ZAHL)
        ulimit = Gzahl((*cast(Zahl*) ul.wert).vor_komma);

      if (ol.typ == WertTyp.GANZE_ZAHL)
        olimit = Gzahl(*cast(Gzahl*) ol.wert);

      else if (ol.typ == WertTyp.NATÜRLICHE_ZAHL)
        olimit = Gzahl(*cast(Nzahl*) ol.wert);

      else if (ol.typ == WertTyp.ZAHL)
        olimit = Gzahl((*cast(Zahl*) ol.wert).vor_komma);

      Gzahl* random = new Gzahl(random_zahl(ulimit, olimit));

      setze_variable(bereich, "rzahl", new Wert(random));

      return Wert();

    case MethodenTyp.INDIZES:
      Wert orig_liste = *cast(Wert*) lies_variable(bereich, "eingabe").wert;

      if (orig_liste.typ != WertTyp.LISTE)
        throw new Fehler("Die Funktion 'indizes' braucht eine Liste als Eingabe!");

      Liste l = *orig_liste.liste;
      Liste indizes = Liste([], new Wert[](l.länge));

      for (size_t i = 0; i < l.länge; i++)
        indizes.werte[i] = Wert(new Nzahl(i));

      setze_variable(bereich, "indizes", new Wert(new Liste(indizes)));

      return Wert();

    case MethodenTyp.LÄNGE:
      Wert orig_liste = *cast(Wert*) lies_variable(bereich, "eingabe").wert;
      if (orig_liste.typ != WertTyp.LISTE)
        throw new Fehler("Die Funktion 'länge' braucht eine Liste als Eingabe!");

      setze_variable(bereich, "länge", new Wert(new Nzahl((*orig_liste.liste).länge)));

      return Wert();
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
      parameter ~= new Erstelle_Variable_Glied("eingabe", WertTyp.INVALID);

    else if (typ == MethodenTyp.ALS_TEXT)
    {
      // Parameter
      parameter ~= new Erstelle_Variable_Glied("eingabe", WertTyp.ZAHL);

      // Return Value
      return_values ~= new Erstelle_Variable_Glied("ausgabe", WertTyp.TEXT);
    }
    else if (typ == MethodenTyp.EINGABE)
    {
      parameter ~= new Erstelle_Variable_Glied("aufforderung", WertTyp.TEXT);
      Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("ausgabe", WertTyp.TEXT);
      return_values ~= evg;
    }
    else if (typ == MethodenTyp.ALS_ZAHL)
    {
      Erstelle_Variable_Glied evg = new Erstelle_Variable_Glied("eingabe", WertTyp.TEXT);
      parameter ~= evg;

      // Return Value
      Erstelle_Variable_Glied rvg = new Erstelle_Variable_Glied("ausgabe", WertTyp.ZAHL);
      return_values ~= rvg;
    }
    else if (typ == MethodenTyp.ZUFÄLLIGE_ZAHL)
    {
      parameter ~= new Erstelle_Variable_Glied("unteres_limit", WertTyp.GANZE_ZAHL);
      parameter ~= new Erstelle_Variable_Glied("oberes_limit", WertTyp.GANZE_ZAHL);

      return_values ~= new Erstelle_Variable_Glied("rzahl", WertTyp.GANZE_ZAHL);
    }
    else if (typ == MethodenTyp.INDIZES)
    {
      parameter ~= new Erstelle_Variable_Glied("eingabe", WertTyp.LISTE);
      return_values ~= new Erstelle_Variable_Glied("indizes", WertTyp.LISTE);
    }
    else if (typ == MethodenTyp.LÄNGE)
    {
      parameter ~= new Erstelle_Variable_Glied("eingabe", WertTyp.LISTE);
      return_values ~= new Erstelle_Variable_Glied("länge", WertTyp.NATÜRLICHE_ZAHL);
    }

    super(parameter, return_values, new BlockGlied());
  }
}
//endregion
//regeion FunktionErstellen_Glied
class FunktionErstellen_Glied : Glied
{
  Funktion_Glied körper;
  dstring var_name;

  override public Wert verwerte(uint bereich)
  {
    Wert* wert = new Wert(WertTyp.FUNKTION, cast(void*) körper);
    erstelle_variable(bereich, var_name, VariablenTyp.FUNKTION, wert);
    return Wert();
  }

  override public void schreibe_baum()
  {
    write("[ERSTELLE_FUNKTION]{" ~ var_name ~ ", ");
    körper.schreibe_baum;
    write("}");
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

  this(BlockGlied körper, dstring variable,
    Erstelle_Variable_Glied[] parameter = [],
    Erstelle_Variable_Glied[] returns = [])
  {
    this.körper = new Funktion_Glied(parameter, returns, körper);
    this.var_name = variable;
  }
}
//endregion
