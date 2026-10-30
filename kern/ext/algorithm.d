module ext.algorithm;

// @ {} [] # \ || != ~

pure nothrow @nogc @safe
bool contains(T)(const T[] liste, const T needle)
{
  for (size_t i = 0; i < liste.length; i++)
  {
    if (needle == liste[i])
      return true;
  }

  return false;
}

///IN PLACE
public pure nothrow @nogc @safe
T[] reverse(T)(T[] array)
{
  if (array.ptr == null || array.length <= 1)
    return array;

  size_t i = 0;
  size_t j = array.length - 1;

  while (i < j)
  {
    T temp = array[i];
    array[i] = array[j];
    array[j] = temp;
    i++;
    j--;
  }

  return array;
}

///IN PLACE - SHARES MEMORY!!!
public pure nothrow @safe // Sollte auch nogc sein
T[] remove(T)(T[] array, size_t i)
{
  if (array.length <= i)
    return array;

  for (size_t index = i; (index + 1) < array.length; index++)
  {
    array[index] = array[index + 1];
  }

  array.length -= 1;

  return array;
}

public pure nothrow @nogc @safe
bool startsWith(T)(const const(T)[] array, const const(T)[] needle)
{
  if (needle.length > array.length)
    return false;

  for (size_t i = 0; i < needle.length; ++i)
  {
    if (array[i] != needle[i])
      return false;
  }

  return true;
}

public pure nothrow @nogc @safe
bool startsWith(T)(const const(T)[] array, const T needle)
{
  return array[0] == needle;
}

public pure nothrow @nogc @safe
bool endsWith(T)(const const(T)[] array, const const(T)[] needle)
{
  if (needle.length > array.length)
    return false;

  size_t offset = array.length - needle.length;

  for (size_t i = 0; i < needle.length; ++i)
  {
    if (array[offset + i] != needle[i])
      return false;
  }

  return true;
}

public pure nothrow @nogc @safe
bool endsWith(T)(const const(T)[] array, const T needle)
{
  return array[$ - 1] == needle;
}

//RETURNS fresh ARRAY!
pure nothrow @safe
T[] filter(T)(const T[] arr, T target)
{
  T[] result;
  foreach (item; arr)
  {
    if (item == target)
    {
      result ~= item;
    }
  }
  return result;
}

import zahl.gzahl : Gzahl;
import zahl.nzahl : Nzahl;

import core.stdc.time : time;
import core.stdc.stdlib : srand, rand, RAND_MAX;

private nothrow @nogc @trusted
ubyte random_ubyte(ubyte max_val)
{
  if (max_val == 0)
    return 0;

  const uint range = cast(uint) max_val + 1;
  const uint limit = (uint(RAND_MAX) / range) * range;

  uint r = cast(uint) rand();
  while (r >= limit)
  {
    r = cast(uint) rand();
  }

  return cast(ubyte)(r % range);
}

public nothrow @trusted
Gzahl random_zahl(Gzahl unteres_limit, Gzahl oberes_limit)
{
  static bool initialisiert = false;
  if (!initialisiert)
  {
    srand(cast(uint) time(null));
    initialisiert = true;
  }

  if (unteres_limit > oberes_limit)
  {
    Gzahl temp = unteres_limit;
    unteres_limit = oberes_limit;
    oberes_limit = temp;
  }

  if (unteres_limit == oberes_limit)
    return unteres_limit;

  Gzahl diff = oberes_limit - unteres_limit;
  Gzahl span = diff + Gzahl(Nzahl([1]));

  const size_t len = span.grösse.länge;
  if (len == 0)
    return unteres_limit;

  const ubyte top_max = span.grösse.werte[len - 1];

  ubyte[] candidate_bytes = new ubyte[len];

  Nzahl candidate = span.grösse;
  while (candidate >= span.grösse)
  {
    for (size_t i = 0; i + 1 < len; i++)
    {
      candidate_bytes[i] = random_ubyte(255);
    }
    candidate_bytes[len - 1] = random_ubyte(top_max);

    bool all_zero = true;
    for (size_t i = 0; i < len; i++)
    {
      if (candidate_bytes[i] != 0)
      {
        all_zero = false;
        break;
      }
    }

    if (all_zero)
      candidate = Nzahl();
    else
      candidate = Nzahl(candidate_bytes);
  }

  return unteres_limit + Gzahl(candidate);
}
