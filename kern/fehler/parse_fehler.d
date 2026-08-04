module fehler.parse_fehler;

import fehler.fehler;

import glied.glied;

import std.conv : to;

class Parse_Fehler : Fehler
{
	this(string msg, size_t line = __LINE__)
	{
		super(msg, line);
	}
}

class Position_Fehler : Parse_Fehler
{
	this(Glied glied, ulong position, ulong linie = __LINE__)
	{
		string msg = "Das Glied " ~ glied.to!string ~ " kann nicht an Position " ~ position.to!string ~ " stehen";

		super(msg, linie);
	}
}

class ListeSeparatorNichtGetrennt_Fehler : Parse_Fehler
{
	this(ulong linie = __LINE__)
	{
		super(
			"In dieser Liste sind die Elemente nicht richtig getrennt.",
			linie
		);
	}
}
