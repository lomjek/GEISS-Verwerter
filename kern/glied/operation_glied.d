module glied.operation_glied;

import glied.glied;
import glied.wert_glied;

import ext.prints;

import operatoren;
import fehler;
import liste;
import zahl;
import wert;

import std.stdio : write, writeln;
import std.array : join, array;
import std.algorithm.searching : canFind;
import std.algorithm : map;
import std.conv : to;

// @ {} [] # \ || != ~

class OperationGlied : Glied
{
  public OperatorenTyp operationenTyp;
  public Glied[2] werte;
  public bool populated = false;

  override void schreibe_baum()
  {
    write("{");
    werte[0].schreibe_baum();
    write(" ");
    write(operationenTyp);
    write(" ");
    werte[1].schreibe_baum();
    write("}");
  }

  override Wert verwerte(uint bereich)
  {
    Wert wert1 = werte[0].verwerte(bereich);
    Wert wert2 = werte[1].verwerte(bereich);
    Wert resultat = Wert();

  ots:
    switch (operationenTyp)
    {
    case OperatorenTyp.PLUS:
      resultat = wert1 + wert2;
      break ots;

    case OperatorenTyp.MINUS:
      resultat = wert1 - wert2;
      break ots;

    case OperatorenTyp.MAL:
      resultat = wert1 * wert2;
      break ots;

    case OperatorenTyp.GETEILT:
      resultat = wert1 / wert2;
      break ots;

    case OperatorenTyp.GLEICH:
      resultat = Wert(new bool(wert1 == wert2));
      break ots;

    case OperatorenTyp.GRÖSSER_ALS:
      resultat = Wert(new bool(wert1 > wert2));
      break ots;

    case OperatorenTyp.KLEINER_ALS:
      resultat = Wert(new bool(wert1 < wert2));
      break ots;

    case OperatorenTyp.GRÖSSER_GLEICH:
      resultat = Wert(new bool(wert1 >= wert2));
      break ots;

    case OperatorenTyp.KLEINER_GLEICH:
      resultat = Wert(new bool(wert1 <= wert2));
      break ots;

    case OperatorenTyp.ANFÜGEN:
      if (wert1.typ != WertTyp.LISTE)
        throw new Fehler("Man kann nur Listen Elemente anfügen.");

      Liste* l = wert1.liste;

      (*l).anfügen(wert2);
      break ots;

    default:
      throw new Fehler(
        "Dieser Operator wurde nicht implementiert..." ~ operationenTyp.to!string);
    }
    return resultat;
  }

  override public bool ist_vollständig()
  {
    return (werte[0]!is null) && (werte[1]!is null);
  }

  this(OperatorenTyp op_typ)
  {
    operationenTyp = op_typ;
  }

  this(OperatorenTyp op_typ, Glied wert1, Glied wert2)
  {
    operationenTyp = op_typ;
    werte[0] = wert1;
    werte[1] = wert2;
  }

  override string toString() const
  {
    return "G(OPERATOR | " ~ this.operationenTyp.to!string ~ ")";
  }
}
