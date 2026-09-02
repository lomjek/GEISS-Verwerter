module zahl.zahl;

import ext.prints;

import std.algorithm : canFind;
import std.range : retro, split;
import std.bigint : BigInt;
import std.bitmanip : littleEndianToNative;
import std.conv : to;

import zahl.bruch;
import zahl.gzahl;
import zahl.nzahl;

// @ {} [] # \ || != ~

struct Zahl
{
  Gzahl vor_komma;
  Bruch nach_komma;

  //MARK: THIS()
  this(const Zahl z)
  {
    this(z.negativ, z.nach_komma, z.werte);
  }

  this(const Gzahl gz)
  {
    this(gz, Bruch());
  }

  this(const Nzahl nz)
  {
    this(Gzahl(nz), Bruch());
  }

  this(const Gzahl vor_komma, const Bruch nach_komma)
  {
    DivisionResultat dr = dividiere(nach_komma.zähler, nach_komma.nenner, false);

    this.werte = addiere(werte, dr.quotient);
    this.nach_komma = Bruch(dr.rest, nach_komma.nenner.dup);

    if (this.nach_komma.zähler.ist_null)
      this.nach_komma.nenner = [];
  }

  //MARK: opCmp
  int opCmp(const Zahl other) const
  {
    if (this.vor_komma.opCmp(other.vor_komma) != 0)
      return this.vor_komma.opCmp(other.vor_komma);

    return this.nach_komma.opCmp(other.nach_komma);
  }

  bool opEquals(const Zahl other) const
  {
    return this.opCmp(other) == 0;
  }

  //MARK: opBinary
  private pure nothrow
  Zahl opBinary(string op, const Zahl other) const
  {
    switch (op)
    {
    case "+":
      return addiere(other);

    case "-":
      return subtrahiere(other);

    case "*":
      return multipliziere(other);

    default:
      debug
      {
        import std.stdio : write, writeln;

        write("FEHLER: Der Operator kann nicht an Nzahl ausgeführt werden: ");
        writeln(op);
      }
      return Zahl();
    }
  }

  private pure nothrow
  Zahl addiere(const Zahl other)
  {
    return Zahl(this.vor_komma + other.vor_komma, this.nach_komma + other.nach_komma);
  }

  private pure nothrow
  Zahl subtrahiere(const Zahl other) const
  {
    if (this.opCmp(other) == -1)
      return Zahl();

    if (this == other)
      return Zahl();

    Gzahl diff_vor = this.vor_komma - other.vor_komma;
    Bruch diff_nach;

    if (this.nach_komma < other.nach_komma)
    {
      diff_vor = diff_vor - Gzahl(1);
      diff_nach = (Bruch(1) + this.nach_komma) - other.nach_komma;
    }
    else
    {
      diff_nach = this.nach_komma - other.nach_komma;
    }

    return Zahl(diff_vor, diff_nach);
  }

  private pure nothrow
  Zahl multipliziere(Zahl other)
  {
    return Zahl(this.vor_komma * other.vor_komma, this.nach_komma * other.nach_komma);
  }
}

//MARK: DIVISON

/// dividiere => Bruch / Bruch = Bruch
/// Funktioniert eigentlich durch multiplikation.
nothrow Bruch dividiere(Bruch num1, Bruch num2)
{
  return Bruch(multipliziere(num1.zähler, num2.nenner), multipliziere(num1.nenner, num2
      .zähler));
}

struct DivisionResultat
{
  ubyte[] quotient;
  ubyte[] rest;
}

/// dividiere => ubyte[] / ubyte[] = DivisionResultat;
/// 0en am Anfang werden nicht weggestrichen.
/// Ich verstehe diesen Algorithmus nicht, aber er funktioniert.
/// => Fast recursive division
DivisionResultat dividiere(const ubyte[] nummer1, const ubyte[] nummer2, bool throw_error = true)
{
  if (nummer2.ist_null)
  {
    if (throw_error)
      throw new Exception("Division durch 0");
    else
      return DivisionResultat([], []);
  }

  ubyte[] num1 = nummer1.dup.right_unpad();
  ubyte[] num2 = nummer2.dup.right_unpad();

  if (num1 == [0] || num1.length == 0)
    return DivisionResultat([0], [0]);

  else if (num1 == num2)
    return DivisionResultat([1], [0]);

  else if (NatürlicheZahl(num2) > NatürlicheZahl(num1))
    return DivisionResultat([0], num1);

  bool ist_ungerade = (num1[0] % 2) != 0;

  DivisionResultat dr = dividiere(int_div_by2(num1), num2);

  dr.quotient = multipliziere(dr.quotient, [2]);
  dr.rest = multipliziere(dr.rest, [2]);

  if (ist_ungerade)
    dr.rest = addiere(dr.rest, [1]);

  while (NatürlicheZahl(dr.rest) >= NatürlicheZahl(num2))
  {
    dr.rest = subtrahiere(dr.rest, num2);
    dr.quotient = addiere(dr.quotient, [1]);
  }

  return dr;
}
