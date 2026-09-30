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

	return Wert(WertTyp.TEXT, new Text(wort.to!string));
}
