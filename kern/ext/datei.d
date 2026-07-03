module ext.datei;

import std.file : exists;
import std.stdio : File;
import std.utf : byDchar;
import std.conv : to;

// @ {} [] # \ || != ~

dstring datei_lesen(dstring path)
{
	if (!exists(path))
	{
		throw new Exception("Die gegebene Datei existiert nicht");
	}

	dchar[] buffer;
	File file = File(path, "r");

	foreach (ubyte[] chunk; file.byChunk(4096))
	{
		foreach (dchar c; (cast(char[]) chunk).byDchar)
		{
			buffer ~= c;
		}
	}

	return buffer.to!dstring;
}
