module zahl.gzahl;

import zahl.nzahl;
import zahl.division;

// @ {} [] # \ || != ~

struct Gzahl
{
  bool positiv = true;

  Nzahl grösse = Nzahl();

  size_t länge() const {
    return grösse.länge;
  }

  const (ubyte)* werte() const {
    return grösse.werte;
  }

  //MARK: THIS()
  pure nothrow
    this(const Nzahl nz)
    {
      this(nz, true);
    }

  pure nothrow
    this(const Nzahl nz, const bool positiv)
    {
      this.grösse = Nzahl(nz);
      if (this.grösse.länge != 0)
        this.positiv = positiv;
    }

  pure nothrow
    this(const Gzahl gz)
    {
      this(gz.grösse, gz.positiv);
    }

  pure nothrow
    this(const ubyte[] werte, const bool positiv)
    {
      this(Nzahl(werte), positiv);
    }

  pure nothrow
    this(const ubyte* werte, const size_t länge, const bool positiv)
    {
      this(Nzahl(werte, länge), positiv);
    }

  //MARK: opCmp
  pure nothrow
    int opCmp(const Gzahl other) const
    {
      if (this.grösse.opCmp(Nzahl.init) == 0 && other.grösse.opCmp(Nzahl.init) == 0)
        return 0;

      if (this.positiv != other.positiv)
        return this.positiv ? 1 : -1;

      int nzahlResult = this.grösse.opCmp(other.grösse);

      if (!this.positiv)
        return -nzahlResult;

      return nzahlResult;
    }

  pure nothrow
    bool opEquals(const Gzahl other) const
    {
      return this.opCmp(other) == 0;
    }

  //MARK: opBinary
  nothrow
    Gzahl opBinary(string op, R)(const R other) const
    {
      static if (is(R == Gzahl))
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
              return Gzahl();
        }
      }
      else static if (is(R == Nzahl))
      {
        return this.opBinary!op(Gzahl(other));
      }
      else
        throw new Parse_Fehler("Typen_Fehler, (Gzahl)");
    }

  //MARK: ADDIERE
  private pure nothrow
    Gzahl addiere(const Gzahl other) const
    {
      if (this.positiv == other.positiv)
      {
        return Gzahl(this.grösse + other.grösse, this.positiv);
      }

      if (this.grösse == other.grösse)
      {
        return Gzahl([], true);
      }
      if (this.grösse > other.grösse)
      {
        return Gzahl(this.grösse - other.grösse, this.positiv);
      }
      else
      {
        return Gzahl(other.grösse - this.grösse, other.positiv);
      }

      //Man sollte hier nie anlangen...
      debug
      {
        import std.stdio : write, writeln;

        write("FEHLER: Diese zwei Zahlen könnte man eigentlich nicht addieren...");
      }
      return Gzahl();
    }

  //MARK: SUBTRAHIERE
  private pure nothrow
    Gzahl subtrahiere(const Gzahl other) const
    {
      if (this == other)
        return Gzahl();

      Gzahl negiertesOther = Gzahl(other.grösse, !other.positiv);
      return addiere(negiertesOther);
    }

  //MARK: MULTIPLIZIERE
  private pure nothrow
    Gzahl multipliziere(const Gzahl other) const
    {
      if ((this.positiv && other.positiv) ||
          (this.positiv == false && other.positiv == false))
        return Gzahl(this.grösse * other.grösse, true);

      return Gzahl(this.grösse * other.grösse, false);
    }

  //MARK: DIVIDIERE
  private pure nothrow
    Gzahl dividiere(const Gzahl other) const
    {
      if (Gzahl(other).grösse.länge == 0)
        return Gzahl();

      DivisionResultat dr = zahl.division.dividiere(this.grösse, other.grösse, false);

      if ((this.positiv && other.positiv) ||
          (this.positiv == false && other.positiv == false))
        return Gzahl(dr.quotient, true);

      return Gzahl(dr.quotient, false);
    }
}
