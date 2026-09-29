module ext.string;

import ext.algorithm : contains, reverse;

import std.conv : to;

// @ {} [] # \ || != ~

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

dstring replaceAll(dstring input, dchar to_replace, dstring with_replace)
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

	return result.to!dstring;
}

dchar[] dchar_from_string(string input)
{
	dchar[] output;

	for (size_t i = 0; i < input.length; i++)
	{
		output ~= input[i];
	}

	return output;
}

const dchar[] default_schars = [' ', '\t', '\n', '\0'];

pure nothrow @safe
dchar[] strip(dstring input, const dchar[] schars = default_schars){
  dchar[] front_strip;

  bool encountered_char = false;
  for (size_t i = 0; i < input.length; i++)
	{
    if (!schars.contains(input[i]))
      encountered_char = true;

    if (encountered_char)
		  front_strip ~= input[i];
	}

  encountered_char = false;
  dchar[] output;

  for (size_t idx = front_strip.length; idx > 0; idx--)
	{
    size_t i = idx - 1;

    if (!schars.contains(front_strip[i]))
      encountered_char = true;

    if (encountered_char)
		  output ~= front_strip[i];
	}

  return output.reverse;
}

pure nothrow
dchar[] strip(dchar[] input, const dchar[] schars = default_schars)
{
  return strip(cast(dstring) input, schars);
}

