module token.schlüsselwörter;

// @ {} [] # \ || != ~

enum SchlüsselWort
{
	INVALID,

	rück_pfeil,
	pro,
	der
}

string[SchlüsselWort] schlüsselWort_dict;

static this()
{
	schlüsselWort_dict[SchlüsselWort.rück_pfeil] = "<-";
	schlüsselWort_dict[SchlüsselWort.pro] = "pro";
	schlüsselWort_dict[SchlüsselWort.der] = "der";
}
