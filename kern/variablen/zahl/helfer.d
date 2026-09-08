module zahl.helfer;

import core.memory : GC;
import core.stdc.string : memcpy;

import zahl.nzahl;

// @ {} [] # \ || != ~

pure nothrow
ubyte* dup(const ubyte* ptr, const ulong länge)
{
  if (ptr == null || länge == 0)
    return null;

  void* mem = GC.malloc(länge, GC.BlkAttr.NO_SCAN);

  memcpy(mem, ptr, länge);

  return (cast(ubyte*) mem);
}

/// In place reversion of ubyte array
pure nothrow
Nzahl reverse(Nzahl arr)
{
  if (arr.länge <= 1)
    return arr;

  size_t i = 0;
  size_t j = cast(size_t) arr.länge - 1;

  while (i < j)
  {
    ubyte temp = arr.werte[i];
    arr.werte[i] = arr.werte[j];
    arr.werte[j] = temp;
    i++;
    j--;
  }

  return arr;
}

/// IN place unpadding of Nzahl
pure nothrow
Nzahl right_unpad(Nzahl num)
{
  size_t last_num = 0;

  for (size_t i; i < num.länge; i++)
  {
    if (num.werte[i] != 0)
      last_num = i;
  }

  num.länge = num.länge - last_num;

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
