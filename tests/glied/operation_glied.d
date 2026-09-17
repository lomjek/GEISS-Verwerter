module tests.glied.operation_glied;

import glied.operation_glied;

import glied.wert_glied;
import variablen.wert;
import zahl;
import operatoren;

import std.stdio : writeln, write;

// @ {} [] # \ || != ~

unittest {
  writeln("    ====================================");
  writeln("    Testiere: glied.operation_glied");
	writeln("    ====================================");

  { // PLUS
    { // ZAHL + ZAHL
      OperationGlied op_gl = new OperationGlied(
          OperatorenTyp.PLUS,
          new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(Nzahl([120])))),
          new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(Gzahl([120], true), Bruch([12], [3]))))
      );

      Wert resultat = op_gl.verwerte(0);
    }
  }

}
