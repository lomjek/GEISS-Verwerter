module token.schlüsselwörter;

import ext.string : dchar_from_string;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
	INVALID,

	PRO,
	DER
}

dchar[][SchlüsselWort] schlüsselWort_dict;

static this()
{
	schlüsselWort_dict[SchlüsselWort.PRO] = "pro".dchar_from_string;
	schlüsselWort_dict[SchlüsselWort.DER] = "der".dchar_from_string;
}
