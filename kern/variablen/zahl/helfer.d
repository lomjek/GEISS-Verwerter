module zahl.helfer;

import core.memory : GC;
import core.stdc.string : memcpy;

import zahl.nzahl;

pure nothrow @safe
ubyte* dup(const ubyte* ptr, const ulong länge)
{
  if (ptr == null || length == 0)
    return null;

  void* mem = GC.malloc(länge, GC.BlkAttr.NO_SCAN);

  memcpy(mem, ptr, länge);

  return (cast(ubyte*) mem);
}

/// In place reversion of ubyte array
ubyte[] reverse(ubyte[] arr)
{
  if (arr.length <= 1)
    return arr;

  size_t i = 0;
  size_t j = cast(size_t) arr.length - 1;

  while (i < j)
  {
    ubyte temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
    i++;
    j--;
  }

  return arr;
}

pure nothrow
ubyte[] right_unpad(const ubyte[] num)
{
  ubyte[] arr = num.dup(num.length);
  arr.reverse();
  ubyte[] unpadded;

  bool encountered_int = false;

  foreach (ubyte key; arr)
  {
    if (encountered_int)
    {
      unpadded ~= key;
    }
    else if (key != 0)
    {
      encountered_int = true;
      unpadded ~= key;
    }
  }

  return unpadded.reverse;
}

/// Essentiel ein grosser ByteShift nach Unten.

ubyte[] int_div_by2(const ubyte[] num)
{
  ubyte[] nummer = num.dup.reverse;

  bool übertragung = false;

  for (ulong i = 0; nummer.length > i; i++)
  {
    ubyte temp = nummer[i];

    nummer[i] = temp >> 1;

    if (übertragung)
      nummer[i] += 0b_1000_0000;

    übertragung = (temp % 2) != 0;
  }

  return reverse(nummer).right_unpad;
}

nothrow
private bool ist_null(const Nzahl num)
{
  for (ulong i = 0; i < num.länge; i++)
  {
    ubyte b = num.grösse[i];

    if (b != 0)
      return false;
  }
  return true;
}
