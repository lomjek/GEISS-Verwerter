module zahl.helfer;

import core.memory : GC;
import core.stdc.string : memcpy;

import zahl.nzahl;
import zahl.division : DivisionResultat, dividiere;

import ext.algorithm : reverse;

// @ {} [] # \ || != ~

pure nothrow
ubyte* dup(const ubyte* ptr, const size_t länge)
{
  if (ptr == null || länge == 0)
    return null;

  void* mem = GC.malloc(länge, GC.BlkAttr.NO_SCAN);

  memcpy(mem, ptr, länge);

  return (cast(ubyte*) mem);
}

/// In place reversion of ubyte array
public pure nothrow @nogc
Nzahl reverse(Nzahl arr)
{
  if (arr.länge <= 1)
    return arr;

  reverse(arr.werte[0 .. arr.länge]);

  return arr;
}

/// IN place unpadding of Nzahl
pure nothrow
Nzahl right_unpad(ref Nzahl num)
{
  if (num.länge == 1 && num.werte[0] == 0)
  {
    num.länge = 0;
    return num;
  }

  size_t last_num = 0;

  for (size_t i = 0; i < num.länge; i++)
  {
    if (num.werte[i] != 0)
      last_num = i;
  }

  num.länge = last_num + 1;

  return num;
}

/// IN place padding of Nzahl
pure nothrow
Nzahl right_pad(ref Nzahl num, size_t target_length)
{
  if (target_length <= num.länge)
    return num;

  ubyte* new_werte = cast(ubyte*) GC.calloc(target_length * ubyte.sizeof);

  if (num.länge > 0 && num.werte !is null)
  {
    new_werte[0 .. num.länge] = num.werte[0 .. num.länge];
    GC.free(num.werte);
  }

  num.werte = new_werte;
  num.länge = target_length;

  return num;
}

pure nothrow
Nzahl potenz(const Nzahl num1, const Nzahl num2)
{
  Nzahl z1 = Nzahl(num1);
  Nzahl z2 = Nzahl(num2);

  while (z2 > Nzahl([1]))
  {
    z1 = num1 * z1;
    z2 = z2 - Nzahl([1]);
  }

  return z1;
}

//GGT via Euklid
pure nothrow
Nzahl ggt(const Nzahl z1, const Nzahl z2)
{
  if (z1 == Nzahl() || z2 == Nzahl())
    return Nzahl();

  Nzahl a = Nzahl(z1);
  Nzahl b = Nzahl(z2);

  DivisionResultat dr = dividiere(a, b);

  while (dr.rest != Nzahl())
  {
    a = b;
    b = dr.rest;

    dr = dividiere(a, b);
  }

  return b;
}
