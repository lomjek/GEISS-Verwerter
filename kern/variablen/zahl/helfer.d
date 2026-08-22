module zahl.helfer;

import core.memory : GC;
import core.stdc.string : memcpy;

pure nothrow @safe
ubyte[] dup(const ubyte* ptr, const ulong länge)
{
  if (ptr == null || length == 0)
    return null;

  void* mem = GC.malloc(länge, GC.BlkAttr.NO_SCAN);

  memcpy(mem, ptr, länge);

  return (cast(ubyte*)mem)[0 .. length];
}

/// In place reversion of ubyte array
ubyte[] reverse(ubyte[] arr)
{
    if (arr.length <= 1)
        return arr;

    size_t i = 0;
    size_t j = arr.length - 1;

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


