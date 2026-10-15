module tests.liste;

import liste;

import variablen.wert;
import variablen.speicher;
import variablen.variable;

// @ {} [] # \ || != ~

unittest
{
  import std.stdio : write, writeln;

  writeln;
  writeln("  Testiere liste");
  writeln("  ====================================");

  Liste l = Liste([WertTyp.NATÜRLICHE_ZAHL], []);

  assert(l.fix_wert_typ == [WertTyp.NATÜRLICHE_ZAHL]);

  //l.anfügen(Wert());

  erstelle_variable(0, "test", VariablenTyp.FIX, new Wert(WertTyp.LISTE, &l));
  Wert w = *cast(Wert*) lies_variable(0, "test").wert;
  if (w.typ != WertTyp.LISTE)
    assert(0);

  Liste li = *cast(Liste*) w.wert;
  writeln(li);
}
