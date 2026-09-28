module variablen.speicher;

import fehler;
import liste;
import zahl;

import variablen.variable;
import variablen.wert;

import glied.funktion_glied;

import ext.string;

import std.conv : to;

debug
{
  import std.stdio : write, writeln;
}

// @ {} [] # \ || != ~

struct Bereich
{
  dstring name;
  uint uid;
  Variable[] variablen;
}

private Bereich*[] bereiche;

static this()
{
  bereiche ~= new Bereich("global"d, 0, [
      Variable(
        "status_nummer"d,
        VariablenTyp.FIX,
        new Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl())
        ), // Exit code 
      Variable(
        "std_wert_nzahl"d,
        VariablenTyp.FIX,
        new Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl())
        ), //Standard Wert, mit welchem nzahlen initialisiert werden.
      Variable(
        "std_wert_gzahl"d,
        VariablenTyp.FIX,
        new Wert(WertTyp.GANZE_ZAHL, new Gzahl(Nzahl(), false))
        ), //Standard Wert, mit welchem gzahlen initialisiert werden.
      Variable(
        "std_wert_zahl"d,
        VariablenTyp.FIX,
        new Wert(WertTyp.ZAHL, new Zahl(Nzahl()))
        ), //Standard Wert, mit welchem zahlen initialisiert werden.
      Variable(
          "std_wert_wahrheit"d,
          VariablenTyp.FIX,
          new Wert(WertTyp.WAHRHEIT, new bool(true))
          ), //Standard Wert, mit welchem wahrheiten initialisiert werden.
      Variable(
          "schreibe"d,
          VariablenTyp.FUNKTION,
          cast(void*)(new EingebauteFunktion_Glied(MethodenTyp.PRINT))
          ), // Schreibe geht momentan nur für strings.
      Variable(
          "als_text"d,
          VariablenTyp.FUNKTION,
          cast(void*)(new EingebauteFunktion_Glied(MethodenTyp.ALS_TEXT))
          ), // Zahl => Text
      Variable(
          "als_zahl"d,
          VariablenTyp.FUNKTION,
          cast(void*)(new EingebauteFunktion_Glied(MethodenTyp.ALS_ZAHL))
          ),
      Variable(
          "eingabe"d,
          VariablenTyp.FUNKTION,
          cast(void*)(new EingebauteFunktion_Glied(MethodenTyp.EINGABE))
          ),

      //Hier müssten so Sachen sein wie name der Datei, eine exit Funktion, usw, usw...
      ]);
}

//MARK: BEREICH
  nothrow
uint initialisiere_bereich(dstring name)
{
  uint bereich_level = 1;

  for (; bereich_level < bereiche.length; bereich_level++)
  {
    if (bereiche[bereich_level] == null)
    {
      break;
    }
  }

  if (bereich_level < bereiche.length)
  {
    bereiche[bereich_level] = new Bereich(name, bereich_level, []);
  }
  else
  {
    bereiche ~= new Bereich(name, bereich_level, []);
    bereich_level = cast(uint) bereiche.length - 1;
  }
  return bereich_level;
}

  nothrow @safe
bool bereich_existiert(uint bereich_num)
{
  if (bereich_num >= bereiche.length)
    return false;

  if (bereiche[bereich_num] == null)
    return false;

  return true;
}

  nothrow
void lösche_bereich(uint bereich_num)
{
  if (bereiche.length > bereich_num)
    bereiche[bereich_num] = null;
}

//MARK: VARIABLEN
  nothrow
private bool variable_existiert(uint bereich_num, dstring var_name)
{
  if (!bereich_num.bereich_existiert)
    return false;

  foreach (Variable var; bereiche[bereich_num].variablen)
  {
    if (var_name == var.identifier)
    {
      return true;
    }
  }
  return false;
}

private dstring[] variablen_namen(uint bereich_num)
{
  if (!bereich_num.bereich_existiert)
  {
    throw new Bereich_Nicht_Existent_Fehler(bereich_num);
  }

  Bereich ber = *bereiche[bereich_num];

  dstring[] namen;

  foreach (Variable var; ber.variablen)
  {
    namen ~= var.identifier;
  }

  return namen;
}

Variable lies_variable(uint bereich_num, dstring var_name)
{
  if (!bereich_num.bereich_existiert)
    throw new Variable_Nicht_Existent_Fehler(var_name, variablen_namen(bereich_num));

  Bereich bereich = *bereiche[bereich_num];

  foreach (Variable var; bereich.variablen)
  {
    if (var.identifier == var_name)
    {
      return var;
    }
  }
  throw new Variable_Nicht_Existent_Fehler(var_name, bereich_num.variablen_namen);
}

void erstelle_variable(uint bereich_num, dstring var_name, VariablenTyp var_typ, Wert* init_wert)
{
  if (!bereich_num.bereich_existiert)
    throw new Bereich_Nicht_Existent_Fehler(bereich_num);

  if (variable_existiert(bereich_num, var_name))
    throw new Variable_Schon_Existent_Fehler(var_name);

  if (init_wert == null)
  {
    switch (init_wert.typ)
    {
      case WertTyp.ZAHL:
        Variable var = lies_variable(0, "std_wert_zahl");
        init_wert = cast(Wert*) var.wert;
        break;

      case WertTyp.GANZE_ZAHL:
        Variable var = lies_variable(0, "std_wert_gzahl");
        init_wert = cast(Wert*) var.wert;
        break;

      case WertTyp.NATÜRLICHE_ZAHL:
        Variable var = lies_variable(0, "std_wert_nzahl");
        init_wert = cast(Wert*) var.wert;
        break;

      case WertTyp.WAHRHEIT:
        Variable var = lies_variable(0, "std_wert_wahrheit");
        init_wert = cast(Wert*) var.wert;
        break;

      case WertTyp.LISTE:
        init_wert.wert = new Liste(true, WertTyp.INVALID, []);
        break;

      case WertTyp.TEXT:
        break;

      case WertTyp.INVALID:
        break;

      default:
        throw new Fehler(
            "Dieser Typ sollte nicht existieren: " ~ init_wert.typ.to!string);
    }
  }
  else if (init_wert.typ == WertTyp.FUNKTION && var_typ == VariablenTyp.FUNKTION)
  {
    bereiche[bereich_num].variablen ~= Variable(var_name, VariablenTyp.FUNKTION, init_wert.wert);
  }

  bereiche[bereich_num].variablen ~= Variable(var_name, var_typ, init_wert);
}

void setze_variable(uint bereich_num, dstring var_name, Wert* neuer_wert)
{
  if (bereiche[bereich_num] == null)
    throw new Error("Der Bereich für die Variable existiert nicht!");
  if (
      !variable_existiert(bereich_num, var_name))
    throw new Variable_Nicht_Existent_Fehler(var_name, bereich_num.variablen_namen);

  Bereich* bereich = bereiche[bereich_num];
  foreach (ref Variable var; bereich.variablen)
  {
    if (var.identifier == var_name)
    {
      // Variable gefunden.
      if (var.var_typ == VariablenTyp.FIX)
      {
        WertTyp vw_typ = (*cast(Wert*) var.wert).typ;
        WertTyp nw_typ = neuer_wert.typ; // Typen sind genau gleich
        if (vw_typ == nw_typ)
        {
          var.wert = neuer_wert;
        }

        // Upcasting für Zahlen  
        else if (nw_typ == WertTyp.GANZE_ZAHL && vw_typ == WertTyp.ZAHL)
        {
          Gzahl nw_gzahl = *cast(Gzahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.ZAHL, new Zahl(nw_gzahl));
          var.wert = nw;
        }

        else if (nw_typ == WertTyp.NATÜRLICHE_ZAHL && vw_typ == WertTyp
            .ZAHL)
        {
          Nzahl nw_nzahl = *cast(Nzahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.ZAHL, new Zahl(nw_nzahl));
          var.wert = nw;
        }

        else if (nw_typ == WertTyp.NATÜRLICHE_ZAHL && vw_typ == WertTyp.GANZE_ZAHL)
        {
          Nzahl nw_nzahl = *cast(Nzahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.GANZE_ZAHL, new Gzahl(nw_nzahl));
          var.wert = nw;
        }
        // Downcasting für Zahlen TODO:VIELLEICHT WARNUNG IMPLEMENTIEREN
        else if (nw_typ == WertTyp.ZAHL && vw_typ == WertTyp.NATÜRLICHE_ZAHL)
        {
          Zahl nw_zahl = *cast(Zahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl(nw_zahl.grösse));
          var.wert = nw;
        }

        else if (nw_typ == WertTyp.GANZE_ZAHL && vw_typ == WertTyp.NATÜRLICHE_ZAHL)
        {
          Gzahl nw_gzahl = *cast(Gzahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl(nw_gzahl.grösse));
          var.wert = nw;
        }

        else if (nw_typ == WertTyp.ZAHL && vw_typ == WertTyp.GANZE_ZAHL)
        {
          Zahl nw_zahl = *cast(Zahl*) neuer_wert.wert;
          Wert* nw = new Wert(WertTyp.GANZE_ZAHL, new Gzahl(nw_zahl.vor_komma));
          var.wert = nw;
        }

        else
        {
          throw new Variable_Assign_Typ_Error(var.identifier, vw_typ, nw_typ);
        }
      }
      else if (var.var_typ == VariablenTyp.VARIABEL)
      {
        var.wert = neuer_wert;
      }
    }
  }
}

//MARK: Global_Helpers
int bekomme_return_status()
{
  Variable var = lies_variable(0, "status_nummer");
  Wert wert = *cast(
      Wert*) var.wert;
  Nzahl zahl = *cast(Nzahl*) wert
    .wert;
  return als_int(zahl);
}

bool hat_variable_typ(uint bereich, dstring indetifier, VariablenTyp vt)
{
  Variable var = lies_variable(bereich, indetifier);
  return var.var_typ == vt;
}

//MARK: DEBUG
debug
{
  void dump_speicher()
  {
    foreach (Bereich* key; bereiche)
    {
      if (key == null)
        continue;

      write(key.name ~ " ("d ~ key.uid.to!dstring ~ "): ["d);

      bool first = true;
      foreach (Variable var; key.variablen)
      {
        if (!first)
          write(", ");

        write(var.als_string);

        first = false;
      }

      writeln("]");
    }
  }
}
