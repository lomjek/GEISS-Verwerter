module zahl.gzahl;

import zahl.nzahl;

// @ {} [] # \ || != ~

struct Gzahl
{
  Nzahl grösse;
  bool positiv = true;

  //MARK: THIS()
  pure nothrow
  this(const Nzahl nz)
  {
    this.grösse = Nzahl(nz);
    this.positiv = true;
  }

  pure nothrow
  this(const Nzahl nz, bool positiv)
  {
    this.grösse = Nzahl(nz);
    this.positiv = positiv;
  }

  pure nothrow
  this(const ubyte[] werte, bool positiv)
  {
    this.grösse = Nzahl(werte);
    this.positiv = positiv;
  }

  pure nothrow
  this(const ubyte* werte, const ubyte länge, bool positiv)
  {
    this.grösse = Nzahl(werte, länge);
    this.positiv = positiv;
  }

  //MARK: opCmp
  int opCmp(ref const Gzahl other) const
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

  bool opEquals(const Gzahl other) const
  {
    return this.opCmp(other) == 0;
  }

  //MARK: opBinary
  private pure nothrow
  Gzahl opBinary(string op, const Gzahl other) const
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
      return Gzahl();
    }
  }

  //MARK: ADDIERE
  private pure nothrow
  Gzahl addiere(const Gzahl other) const
  {
    if (this.positiv == other.positiv)
    {
      return Gzahl(this.positiv, this.grösse + other.grösse);
    }

    if (this.positiv && other.positiv == false)
    {
      return subtrahiere(num1, num2);
    }
    else if (this.positiv == false && other.positiv)
    {
      return subtrahiere(num2, num1);
    }

    //Man sollte hier nie anlangen...
    debug
    {
      import std.stdio : write, writeln;

      write("FEHLER: Der Operator kann nicht an Nzahl ausgeführt werden: ");
      writeln(op);
    }
    return Gzahl();
  }

  //MARK: SUBTRAHIERE
  private pure nothrow
  Gzahl subtrahiere(const Gzahl other) const
  {
    if (this.opCmp(other) == -1)
      return Gzahl();

    if (this == other)
      return Gzahl();

    Gzahl negiertesOther = Gzahl(other.grösse, !other.positiv);
    return addiere(negiertesOther);
  }

  //MARK: MULTIPLIZIERE
  private pure nothrow
  Gzahl multipliziere(Gzahl num1, Gzahl num2)
  {
    if ((num1.negativ && num2.negativ) ||
      (num1.negativ == false && num2.negativ == false))
      return Gzahl(false, this.grösse * other.grösse);

    return Gzahl(true, this.grösse * other.grösse);
  }
}
