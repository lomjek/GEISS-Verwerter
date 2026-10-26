module zahl.zahl;

import ext.prints;

import zahl.division;
import zahl.bruch;
import zahl.gzahl;
import zahl.nzahl;
import zahl.helfer : dup;

import fehler.parse_fehler;

// @ {} [] # \ || != ~

struct Zahl
{
  Gzahl vor_komma = Gzahl();

  bool positiv() const
  {
    return vor_komma.positiv;
  }

  size_t länge() const
  {
    return vor_komma.grösse.länge;
  }

  const(ubyte)* werte() const
  {
    return vor_komma.grösse.werte;
  }

  const(Nzahl) grösse() const
  {
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

  this(const Nzahl nz, const Bruch b)
  {
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

          write("FEHLER: Der Operator kann nicht an Zahl ausgeführt werden: ");
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
      throw new Parse_Fehler("Typen_Fehler, (Zahl), " ~ R.stringof);

  }

  private
  Bruch als_bruch() const
  {
    Nzahl nenner = this.nach_komma.nenner.länge == 0 ? Nzahl([1]) : Nzahl(this.nach_komma.nenner);
    Nzahl abs_vor = Nzahl(this.vor_komma.grösse);
    Nzahl zähler_abs = (abs_vor * nenner) + this.nach_komma.zähler;

    return Bruch(zähler_abs, nenner);
  }

  private
  Zahl addiere(const Zahl other) const
  {
    Bruch resultat;
    bool presultat;

    if (this.positiv == other.positiv)
    {
      resultat = this.als_bruch + other.als_bruch;
      presultat = this.positiv;
    }
    else if (this.als_bruch == other.als_bruch)
    {
      presultat = true;
      resultat = Bruch();
    }
    else if (this.als_bruch > other.als_bruch)
    {
      resultat = this.als_bruch - other.als_bruch;
      presultat = this.positiv;
    }
    else
    {
      resultat = other.als_bruch - this.als_bruch;
      presultat = other.positiv;
    }

    return Zahl(Gzahl([], presultat), resultat);
  }

  private
  Zahl subtrahiere(const Zahl other) const
  {
    if (this == other)
      return Zahl();

    Zahl negiertesOther = Zahl(Gzahl(other.grösse, !other.positiv), other.nach_komma);
    return addiere(negiertesOther);
  }

  private
  Zahl multipliziere(const Zahl other) const
  {
    Gzahl z1_zähler = Gzahl(this.vor_komma);
    Gzahl z2_zähler = Gzahl(other.vor_komma);

    Bruch b1 = Bruch(z1_zähler.grösse, Nzahl([1])) + this.nach_komma;
    Bruch b2 = Bruch(z2_zähler.grösse, Nzahl([1])) + other.nach_komma;

    if (!this.positiv)
      b1.zähler = b1.zähler;

    if (!other.positiv)
      b2.zähler = b2.zähler;

    Bruch produkt = b1 * b2;

    return Zahl(Gzahl(), produkt);
  }

  private
  Zahl dividiere(const Zahl other) const
  {
    Gzahl z1_zähler = Gzahl(this.vor_komma);
    Gzahl z2_zähler = Gzahl(other.vor_komma);

    Bruch b1 = Bruch(z1_zähler.grösse, Nzahl([1])) + this.nach_komma;
    Bruch b2 = Bruch(z2_zähler.grösse, Nzahl([1])) + other.nach_komma;

    if (!this.positiv)
      b1.zähler = b1.zähler;
    if (!other.positiv)
      b2.zähler = b2.zähler;

    Bruch quotient = b1 / b2;

    return Zahl(Gzahl(), quotient);
  }
}
