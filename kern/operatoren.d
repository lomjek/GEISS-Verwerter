module operatoren;

enum OperatorenTyp
{
	INVALID,

	PLUS,
	MINUS,
	MAL,
	GETEILT,
	HOCH,

	GLEICH,

	RÜCK_PFEIL,
	VOR_PFEIL,

	KLAMMER_AUF,
	KLAMMER_ZU,
	ECKIGE_KLAMMER_AUF,
	ECKIGE_KLAMMER_ZU,

	KLEINER_ALS,
	GRÖSSER_ALS,

	GESCHWUNGENE_KLAMMER_AUF,
	GESCHWUNGENE_KLAMMER_ZU,

	PUNKT,
	KOMMA,
	DOPPELPUNKT,
	SEMIKOLON,

	NEUE_LINIE,
	ANFANG_LINIE,
}

immutable dchar[OperatorenTyp] operatoren_chars = [
	OperatorenTyp.INVALID: '\0',

	OperatorenTyp.PLUS: '+',
	OperatorenTyp.MINUS: '-',
	OperatorenTyp.MAL: '*',
	OperatorenTyp.GETEILT: '/',
	OperatorenTyp.HOCH: '^',

	OperatorenTyp.GLEICH: '=',

	OperatorenTyp.RÜCK_PFEIL: '←',
	OperatorenTyp.VOR_PFEIL: '→',

	OperatorenTyp.KLAMMER_AUF: '(',
	OperatorenTyp.KLAMMER_ZU: ')',
	OperatorenTyp.ECKIGE_KLAMMER_AUF: '[',
	OperatorenTyp.ECKIGE_KLAMMER_ZU: ']',

	OperatorenTyp.KLEINER_ALS: '<',
	OperatorenTyp.GRÖSSER_ALS: '>',

	OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF: '{',
	OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU: '}',

	OperatorenTyp.PUNKT: '.',
	OperatorenTyp.KOMMA: ',',
	OperatorenTyp.DOPPELPUNKT: ':',
	OperatorenTyp.SEMIKOLON: ';',

	OperatorenTyp.NEUE_LINIE: '\n',
	OperatorenTyp.ANFANG_LINIE: '\r'
];
