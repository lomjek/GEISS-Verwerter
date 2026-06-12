module schlüsselwörter;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
	INVALID,

	PRO,
	DER,

	FALLS,
	SONST,

}

immutable dstring[SchlüsselWort] schlüsselWort_dict = [
	SchlüsselWort.PRO: "pro"d,
	SchlüsselWort.DER: "der"d,

	SchlüsselWort.FALLS: "falls"d,
	SchlüsselWort.SONST: "sonst"d
];
