module token.operatoren;

enum OperatorenTyp
{
	PLUS,
	MINUS,
	MAL,
	GETEILT,
	HOCH,

	RÜCK_PFEIL,
	VOR_PFEIL,

	KLAMMER_AUF,
	KLAMMER_ZU,
	ECKIGE_KLAMMER_AUF,
	ECKIGE_KLAMMER_ZU,
	SPITZE_KLAMMER_AUF,
	SPITZE_KLAMMER_ZU,
	GESCHWUNGENE_KLAMMER_AUF,
	GESCHWUNGENE_KLAMMER_ZU,

	PUNKT,
	KOMMA,
}

dchar[OperatorenTyp] operatoren_chars;

static this()
{
	operatoren_chars[OperatorenTyp.PLUS] = '+';
	operatoren_chars[OperatorenTyp.MINUS] = '-';
	operatoren_chars[OperatorenTyp.MAL] = '*';
	operatoren_chars[OperatorenTyp.GETEILT] = '/';
	operatoren_chars[OperatorenTyp.HOCH] = '^';

	operatoren_chars[OperatorenTyp.RÜCK_PFEIL] = '←';
	operatoren_chars[OperatorenTyp.VOR_PFEIL] = '→';

	operatoren_chars[OperatorenTyp.KLAMMER_AUF] = '(';
	operatoren_chars[OperatorenTyp.KLAMMER_ZU] = ')';
	operatoren_chars[OperatorenTyp.ECKIGE_KLAMMER_AUF] = '[';
	operatoren_chars[OperatorenTyp.ECKIGE_KLAMMER_ZU] = ']';
	operatoren_chars[OperatorenTyp.SPITZE_KLAMMER_AUF] = '<';
	operatoren_chars[OperatorenTyp.SPITZE_KLAMMER_ZU] = '>';
	operatoren_chars[OperatorenTyp.GESCHWUNGENE_KLAMMER_AUF] = '{';
	operatoren_chars[OperatorenTyp.GESCHWUNGENE_KLAMMER_ZU] = '}';

	operatoren_chars[OperatorenTyp.PUNKT] = '.';
	operatoren_chars[OperatorenTyp.KOMMA] = ',';
}
