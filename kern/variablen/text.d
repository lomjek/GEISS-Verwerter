module text;

import wert;

import fehler;
import ext.string : replaceAll;
import operatoren : OperatorenTyp, operatoren_chars;

import ext.algorithm : startsWith, endsWith, contains;

import std.conv : to;
import std.traits : EnumMembers;
import std.string : strip;

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
    return Text(this);
  }
}

immutable dstring[] string_delims = [
  "\\\'"d, "\\\""d, "\'"d, "\""d
];

pure nothrow
bool beginnt_text(dstring wort)
{

  foreach (dstring delim; string_delims)
  {
    if (wort.strip.startsWith(delim) && wort.length == delim.length)
    {
      return true;
    }

    if (wort.strip.startsWith(delim) && wort.strip.endsWith(delim))
    {
      return true;
    }
    else if (wort.strip.startsWith(delim))
    {
      return true;
    }
  }

  return false;
}

private pure nothrow
bool braucht_space(const dstring[] wort_liste, ulong* wort_index, const dchar[] gesammelt)
{
  if (gesammelt.length == 0)
    return false;

  if (gesammelt[$ - 1] == ' ')
    return false;

  dstring c_wort = wort_liste[*wort_index];
  if (c_wort.length == 0)
    return false;

  if (operatoren_chars.values.contains(gesammelt[$ - 1]))
    return false;

  if (operatoren_chars.values.contains(c_wort[0]))
    return false;

  return true;
}

Text als_wert_text(dstring[] wort_liste, ulong* wort_index)
{
  if (!wort_liste[*wort_index].beginnt_text)
    throw new Fehler("Das hier ist kein Text");

  dstring erstes_wort = wort_liste[*wort_index].strip;

  dstring delim;
  foreach (dstring d; string_delims)
  {
    if (erstes_wort.startsWith(d))
    {
      delim = d;
      break;
    }
  }

  dstring rest_erstes = erstes_wort[delim.length .. $];

  if (rest_erstes.endsWith(delim))
  {
    dstring inhalt = rest_erstes[0 .. $ - delim.length];
    return Text(inhalt.to!string);
  }

  dchar[] gesammelt;
  gesammelt ~= rest_erstes;

  (*wort_index)++;

  while (*wort_index < wort_liste.length)
  {
    if (wort_liste[*wort_index].strip.endsWith(delim))
      break;

    if (wort_liste[*wort_index].length == 0)
    {
      gesammelt ~= ' ';
      (*wort_index)++;
      continue;
    }

    if (braucht_space(wort_liste, wort_index, gesammelt))
    {
      gesammelt ~= ' ';
    }

    gesammelt ~= wort_liste[*wort_index];
    (*wort_index)++;
  }

  if (*wort_index >= wort_liste.length)
    throw new Fehler("Die Anführungszeichen wurden nie geschlossen.");

  if (wort_liste[*wort_index].length == 0)
  {
    gesammelt ~= ' ';
  }

  dstring letztes_wort = wort_liste[*wort_index][0 .. $ - delim.length];
  if (letztes_wort.length > 0)
  {
    if (gesammelt.length > 0 && gesammelt[$ - 1] != ' ' &&
      !operatoren_chars.values.contains(gesammelt[$ - 1]) &&
      !operatoren_chars.values.contains(letztes_wort[0]))
    {
      gesammelt ~= ' ';
    }
    gesammelt ~= letztes_wort;
  }

  return Text(gesammelt.to!string);
}
