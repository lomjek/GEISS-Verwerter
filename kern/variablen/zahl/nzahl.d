module zahl.nzahl;

import zahl.helfer;
import zahl.division;

import core.memory : GC;

// @ {} [] # \ || != ~

/**
 * Nzahl oder eine natürliche Zahl ist praktisch ein slice mit
 * ubytes, welches eine Zahl darstellt.
 */
struct Nzahl
{
  ubyte* werte = null;
  size_t länge = 0;

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
    this.werte = dup(werte, länge).right_unpad;
    this.länge = länge;
  }

  //MARK: opCmp
  pure nothrow
  int opCmp(const Nzahl other) const
  {
    ubyte[] num1 = right_unpad(werte.dup);
    ubyte[] num2 = right_unpad(other.werte.dup);

    if (num1.length != num2.length)
      return num1.length < num2.length ? -1 : 1;

    foreach_reverse (i; 0 .. num1.length)
    {
      if (num1[i] != num2[i])
        return num1[i] < num2[i] ? -1 : 1;
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
    ulong max_len = this.länge > other.länge ? this.länge : other.länge;

    ubyte[] resultat;
    ubyte überschuss = 0;
    ushort summe = 0;

    for (ulong i = 0; i < max_len; i++)
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
    if (this.opCmp(other) == -1)
      return Nzahl();

    if (this == other)
      return [0];

    ulong max_len = this.länge > other.länge ? this.länge : other.länge;
    Nzahl resultat = Nzahl(GC.malloc(max_len, GC.BlkAttr.NO_SCAN), max_len);

    ushort buffer;
    ubyte carry_over;
    for (ulong i = 0; i < sub.length; i++)
    {
      buffer = min[i];
      ushort subtr = cast(ushort)(sub[i] + carry_over);

      if (min[i] < subtr)
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
      Nzahl();

    return resultat;
  }

  //MARK: MULTIPLIZIERE
  private pure nothrow
  Nzahl multipliziere(const Nzahl other) const
  {
    ubyte[][] matrix;

    if (this.länge == 0 || other.länge == 0)
      return [0];

    if ((this.länge == 1 && this.werte[0] == 0) || (other.länge == 1 && other.werte[0] == 0))
      return [0];

    for (ulong i = 0; i < other.length; i++)
    {
      ubyte[] zwischenresultat = [];
      ubyte überschuss = 0;

      ulong repeat = i;
      while (repeat != 0)
      {
        zwischenresultat ~= 0;
        repeat--;
      }

      for (ulong j = 0; j < this.länge; j++)
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
      matrix[0] = addiere(matrix[0], matrix[1]);
      matrix = matrix.remove(1);
    }

    return matrix[0];
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

    DivisionResultat dr = dividiere(this, other);

    return dr.quotient;
  }
}
