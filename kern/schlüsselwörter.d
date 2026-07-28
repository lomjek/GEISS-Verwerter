module schlüsselwörter;

import glied.glied : SW_Glied, Glied;
import glied.block_glied : Falls_BlockGlied, Sonst_BlockGlied, Solange_BlockGlied;

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

Glied baue_richtiges_sw_glied(SchlüsselWort sw)
{
	switch (sw)
	{
	case SchlüsselWort.FALLS:
		return new Falls_BlockGlied();

	case SchlüsselWort.SONST:
		return new Sonst_BlockGlied();

	case SchlüsselWort.SOLANGE:
		return new Solange_BlockGlied();

	default:
		return new SW_Glied(sw);
	}
}
