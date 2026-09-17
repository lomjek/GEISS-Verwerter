module zahl.zahl;

import ext.prints;

import zahl.division;
import zahl.bruch;
import zahl.gzahl;
import zahl.nzahl;
import zahl.helfer : dup;

// @ {} [] # \ || != ~

struct Zahl
{
  Gzahl vor_komma = Gzahl();

  bool positiv() const {
    return vor_komma.positiv;
  }

  size_t länge() const {
    return vor_komma.grösse.länge;
  }

  const (ubyte)* werte() const {
    return vor_komma.grösse.werte;
  }

  const(Nzahl) grösse() const {
    return vor_komma.grösse;
  }

  Bruch nach_komma;

  //MARK: THIS()
  this(const Zahl z)
  {
    this(z.vor_komma, z.nach_komma);
  }

  this(const Gzahl gz)
  {
    this(gz, Bruch());
  }

  this(const Nzahl nz)
  {
    this(Gzahl(nz), Bruch());
  }

  this(const Nzahl nz, const Bruch b){
    this(Gzahl(nz), b);
  }

  this(const Gzahl vor_komma, const Bruch nach_komma)
  {
    DivisionResultat dr = zahl.division.dividiere(nach_komma.zähler, nach_komma.nenner, false);

    this.vor_komma = vor_komma + Gzahl(dr.quotient);
    this.nach_komma = Bruch(dr.rest, Nzahl(nach_komma.nenner));

    if (this.nach_komma.zähler.länge == 0)
      this.nach_komma.nenner = Nzahl();
  }

  this(const ubyte* werte, const size_t länge, const bool positiv, const Bruch nach_komma)
  {
    this(Gzahl(werte, länge, positiv), nach_komma);
  }

  //MARK: opCmp
  pure nothrow
  int opCmp(const Zahl other) const
  {
    if (this.vor_komma.opCmp(other.vor_komma) != 0)
      return this.vor_komma.opCmp(other.vor_komma);

    return this.nach_komma.opCmp(other.nach_komma);
  }

  pure nothrow
  bool opEquals(const Zahl other) const
  {
    return this.opCmp(other) == 0;
  }

  //MARK: opBinary
  Zahl opBinary(string op, R)(const R other) const
  {
    static if (is(R == Zahl))
    {
      switch (op)
      {
      case "+":
        return addiere(other);

      case "-":
        return subtrahiere(other);

      case "*":
        return multipliziere(other);

      case "/":
        return dividiere(other);

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
    else static if (is(R == Gzahl))
    {
      return this.opBinary!op(Zahl(other));
    }
    else static if (is(R == Nzahl))
    {
      return this.opBinary!op(Zahl(other));
    }
    else
      throw new Parse_Fehler("Typen_Fehler, (Zahl)");

  }

  private
  Zahl addiere(const Zahl other) const
  {
    return Zahl(this.vor_komma + other.vor_komma, this.nach_komma + other.nach_komma);
  }

  private
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
      diff_vor = diff_vor - Gzahl([1], true);
      diff_nach = (Bruch([1], [1]) + this.nach_komma) - other.nach_komma;
    }
    else
    {
      diff_nach = this.nach_komma - other.nach_komma;
    }

    return Zahl(diff_vor, diff_nach);
  }

  private
  Zahl multipliziere(const Zahl other) const
  {
    return Zahl(this.vor_komma * other.vor_komma, this.nach_komma * other.nach_komma);
  }

  private
  Zahl dividiere(const Zahl other) const
  {
    DivisionResultat dr_vor_komma = zahl.division.dividiere(this.grösse, other.grösse);
    Gzahl neu_vor_komma = dr_vor_komma.quotient;

    Bruch dr_nach_komma = this.nach_komma / other.nach_komma;
    Bruch neu_nach_komma = dr_nach_komma + Bruch(dr_vor_komma.rest, Nzahl([1]));

    return Zahl(neu_vor_komma, neu_nach_komma);
  }
}
