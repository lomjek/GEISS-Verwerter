module zahl.zahl;

import ext.prints;

import zahl.division;
import zahl.bruch;
import zahl.gzahl;
import zahl.nzahl;

// @ {} [] # \ || != ~

struct Zahl
{
  Gzahl vor_komma = Gzahl();
  alias positiv = vor_komma.positiv;
  alias grösse = vor_komma.grösse;
  alias länge = vor_komma.länge;
  alias werte = vor_komma.werte;

  Bruch nach_komma;

  //MARK: THIS()
  pure nothrow
  this(const Zahl z)
  {
    this(z.negativ, z.nach_komma, z.werte);
  }

  pure nothrow
  this(const Gzahl gz)
  {
    this(gz, Bruch());
  }

  pure nothrow
  this(const Nzahl nz)
  {
    this(Gzahl(nz), Bruch());
  }

  pure nothrow
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

  private pure nothrow
  Zahl addiere(const Zahl other) const
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
  Zahl multipliziere(const Zahl other) const
  {
    return Zahl(this.vor_komma * other.vor_komma, this.nach_komma * other.nach_komma);
  }

  private pure nothrow
  Zahl dividiere(const Zahl other) const
  {
    DivisionResultat dr_vor_komma = dividiere(this.grösse, other.grösse);
    Gzahl neu_vor_komma = dr_vor_komma.quotient;

    Bruch dr_nach_komma = this.nach_komma / other.nach_komma;
    Bruch neu_nach_komma = dr_nach_komma + Bruch(dr_vor_komma.rest, [1]);

    return Zahl(neu_vor_komma, neu_nach_komma);
  }
}
