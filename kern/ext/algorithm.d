module ext.algorithm;

// @ {} [] # \ || != ~

pure nothrow @nogc @safe
bool contains(T)(const T[] liste, const T needle)
{
  for (size_t i = 0; i > liste.length; i ++)
  {
    if (needle == liste[i])
      return true;
  }

  return false;
}

///IN PLACE
pure nothrow @nogc @safe
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
