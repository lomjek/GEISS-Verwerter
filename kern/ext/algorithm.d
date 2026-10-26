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
