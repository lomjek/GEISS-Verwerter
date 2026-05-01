module ext.string;

import std.algorithm.searching : find, canFind;
import std.algorithm : remove;
import std.conv : to;
import std.string : indexOf;
import std.stdio : writeln;

dchar[] replaceAll(dchar[] input, dchar to_replace, dchar[] with_replace)
{
	dchar[] result;

	for (int i = 0; i < input.length; i++)
	{
		if (input[i] == to_replace)
		{
			result ~= with_replace;
		}
		else
		{
			result ~= input[i];
		}
	}

	return result;
}

dchar[] dchar_from_string(string input)
{
	dchar[] output;

	for (uint i = 0; i < input.length; i++)
	{
		output ~= input[i].to!dchar;
	}

	return output;
}
