module zahl.helfer;

import core.memory : GC;
import core.stdc.string : memcpy;

import zahl.nzahl;

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

pure nothrow
ubyte[] right_unpad(const ubyte[] num)
{
  ubyte[] arr = num.dup(num.länge);
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
