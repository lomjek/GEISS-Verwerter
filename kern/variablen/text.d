module text;

import wert;

import leser : Verifizierung;

import std.algorithm : startsWith, endsWith;
import std.conv : to;

// @ {} [] # \ || != ~

// This is a simple wrapper, to avoid complex stuff, and just put everything on the heap.
struct Text
{
  string str;

  this(string str)
  {
    this.str = str;
  }

  this(Text text)
  {
    this.str = text.str;
  }

  int opCmp(const Text other) const
  {
    return -1; // TODO: IMplement
  }

  Text opBinary(string op, T)(T other)
  {
    return Text();
  }
}

Wert als_wert_text(dstring wort)
{
  if ((wort.startsWith("'") && wort.endsWith("'")) || (wort.startsWith('"') && wort.endsWith('"')))
  {
    wort = wort[1 .. $ - 1];
  }
  else if ((wort.startsWith("\\'") && wort.endsWith("\\'")) || (wort.startsWith("\\\"") && wort.endsWith(
      "\\\"")))
  {
    wort = wort[2 .. $ - 2];
  }

  return Wert(new Text(wort.to!string));
}
