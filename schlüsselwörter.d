module schlüsselwörter;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
	INVALID,

	PRO,
	DER,

	FALLS,
	SONST,

	SOLANGE,
	NICHT,
}

immutable dstring[SchlüsselWort] schlüsselWort_dict = [
	SchlüsselWort.PRO: "pro"d,
	SchlüsselWort.DER: "der"d,

	SchlüsselWort.FALLS: "falls"d,
	SchlüsselWort.SONST: "sonst"d,

	SchlüsselWort.SOLANGE: "solange"d,
	SchlüsselWort.NICHT: "nicht"d,

];
