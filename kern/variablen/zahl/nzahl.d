module zahl.nzahl;

import zahl.helfer;
import zahl.division;

import fehler.parse_fehler;

import core.memory : GC;

import ext.algorithm : remove;

// @ {} [] # \ || != ~

/**
 * Nzahl oder eine natürliche Zahl ist praktisch ein slice mit
 * ubytes, welches eine Zahl darstellt.
 */
struct Nzahl
{
  size_t länge = 0;
  ubyte* werte = null;

  //MARK: THIS()
  pure nothrow
  this(const Nzahl nz)
  {
    this(nz.werte, nz.länge);
  }

  pure nothrow
  this(const ubyte[] werte)
  {
    this(werte.ptr, werte.length);
  }

  pure nothrow
  this(const ubyte* werte, const size_t länge)
  {
    if (werte != null && länge != 0)
    {
      this.werte = dup(werte, länge);
      this.länge = länge;
      this.right_unpad;
    }
  }

  pure nothrow
  this(size_t wert)
  {
    if (wert == 0)
    {
      ubyte[] n = [0];
      this(n.ptr, 1);
      return;
    }

    ubyte[size_t.sizeof] zahl;
    size_t len = 0;
    while (wert > 0)
    {
      zahl[len++] = cast(ubyte)(wert & 0xFF);
      wert = wert >> 8;
    }
    this(zahl.ptr, len);
  }

  //MARK: opCmp
  pure nothrow
  int opCmp(const Nzahl other) const
  {
    Nzahl oth = Nzahl(other);

    if (this.länge != oth.länge)
      return this.länge < oth.länge ? -1 : 1;

    foreach_reverse (i; 0 .. this.länge)
    {
      if (this.werte[i] != oth.werte[i])
        return this.werte[i] < oth.werte[i] ? -1 : 1;
    }

    return 0;
  }

  pure nothrow
  bool opEquals(const Nzahl other) const
  {
    return this.opCmp(other) == 0;
  }

  //MARK: opBinary
  Nzahl opBinary(string op, R)(const R other) const
  {
    static if (is(R == Nzahl))
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

      case "%":
        return modulo(other);

      default:
        debug
        {
          import std.stdio : write, writeln;

          write("FEHLER: Der Operator kann nicht an Nzahl ausgeführt werden: ");
          writeln(op);
        }
        return Nzahl();
      }
    }
    else
      throw new Parse_Fehler("Typen_Fehler, (Nzahl)");
  }

  //MARK: ADDIERE
  private pure nothrow
  Nzahl addiere(const Nzahl other) const
  {
    size_t max_len = this.länge > other.länge ? this.länge : other.länge;

    ubyte[] resultat;
    resultat.reserve(max_len + 1);
    ubyte überschuss = 0;
    ushort summe = 0;

    for (size_t i = 0; i < max_len; i++)
    {
      if (i < this.länge && i < other.länge)
        summe = cast(ushort)(this.werte[i] + other.werte[i] + überschuss);

      else if (i < this.länge)
        summe = cast(ushort)(this.werte[i] + überschuss);

      else if (i < other.länge)
        summe = cast(ushort)(other.werte[i] + überschuss);

      überschuss = cast(ubyte)(summe >> 8);
      resultat ~= cast(ubyte)(summe & 0xFF);
    }

    if (überschuss)
      resultat ~= überschuss;

    return Nzahl(resultat);
  }

  //MARK: SUBTRAHIERE
  private pure nothrow
  Nzahl subtrahiere(const Nzahl other) const
  {
    Nzahl debg = Nzahl(this);

    if (this.opCmp(other) == -1)
      return Nzahl();

    if (this == other)
      return Nzahl();

    ubyte[] resultat = [];
    resultat.reserve(other.länge > this.länge ? other.länge : this.länge);

    ushort buffer;
    ubyte carry_over = 0;
    for (size_t i = 0; i < this.länge; i++)
    {
      buffer = this.werte[i];
      ushort subtr = cast(ushort)((i < other.länge ? other.werte[i] : 0) + carry_over);

      if (buffer < subtr)
      {
        buffer += 0x100; // 0x100 ist die Erste Zahl die grösser ist, als der jetztige buffer;
        carry_over = 0x1;
      }
      else
      {
        carry_over = 0;
      }

      resultat ~= cast(ubyte)(buffer - subtr);
    }

    if (carry_over != 0)
      return Nzahl();

    return Nzahl(resultat);
  }

  //MARK: MULTIPLIZIERE
  private pure nothrow
  Nzahl multipliziere(const Nzahl other) const
  {
    ubyte[][] matrix;

    if (this.länge == 0 || other.länge == 0)
      return Nzahl();

    if ((this.länge == 1 && this.werte[0] == 0) || (other.länge == 1 && other.werte[0] == 0))
      return Nzahl();

    for (size_t i = 0; i < other.länge; i++)
    {
      ubyte[] zwischenresultat = [];
      ubyte überschuss = 0;

      size_t repeat = i;
      while (repeat != 0)
      {
        zwischenresultat ~= 0;
        repeat--;
      }

      for (size_t j = 0; j < this.länge; j++)
      {
        ushort ziffer = (this.werte[j] * other.werte[i]) + überschuss;
        überschuss = cast(ubyte)(ziffer >> 8); //oberer Byte des ushort, was übertragen wird...
        zwischenresultat ~= cast(ubyte)(ziffer & 0xFF); // tieferer Byte des ushorts, was an der Stelle eingetragen wird.
      }

      if (überschuss > 0)
      {
        zwischenresultat ~= überschuss;
      }

      matrix ~= zwischenresultat;
    }

    while (matrix.length > 1)
    {
      Nzahl summe = Nzahl(matrix[0]) + Nzahl(matrix[1]);
      matrix[0] = summe.werte[0 .. summe.länge];
      matrix = matrix.remove(1);
    }

    return Nzahl(matrix[0]);
  }

  //MARK: DIVIDIERE
  private pure nothrow
  Nzahl dividiere(const Nzahl other) const
  {
    Nzahl anders = Nzahl(other);

    if (anders.länge == 0)
    {
      return Nzahl();
    }

    DivisionResultat dr = zahl.division.dividiere(this, other);

    return dr.quotient;
  }

  //MARK: MODULO
  private pure nothrow
  Nzahl modulo(const Nzahl other) const
  {
    DivisionResultat dr = zahl.division.dividiere(Nzahl(this), Nzahl(other));
    return dr.rest;
  }
}
