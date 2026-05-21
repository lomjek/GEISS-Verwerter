module token.schlüsselwörter;

import ext.string : dchar_from_string;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
	INVALID,

	PRO,
	DER
}

immutable dstring[SchlüsselWort] schlüsselWort_dict = [
	SchlüsselWort.PRO: "pro"d,
	SchlüsselWort.DER: "der"d
];
