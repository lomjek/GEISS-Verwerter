module zahl.division;

import zahl.helfer : right_unpad, dup, reverse;
import zahl.nzahl : Nzahl;

// @ {} [] # \ || != ~

struct DivisionResultat
{
	Nzahl quotient;
	Nzahl rest;
}

pure nothrow
Nzahl int_div_by2(const Nzahl num)
{
	Nzahl nummer = Nzahl(num).reverse;

	bool übertragung = false;

	for (ulong i = 0; nummer.länge > i; i++)
	{
		ubyte temp = nummer.werte[i];

		nummer.werte[i] = temp >> 1;

		if (übertragung)
			nummer.werte[i] += 0b_1000_0000;

		übertragung = (temp % 2) != 0;
	}

	return Nzahl(reverse(nummer));
}

/// dividiere => ubyte[] / ubyte[] = DivisionResultat;
/// 0en am Anfang werden nicht weggestrichen.
/// Ich verstehe diesen Algorithmus nicht, aber er funktioniert.
/// => Fast recursive division
pure nothrow
DivisionResultat dividiere(const Nzahl nummer1, const Nzahl nummer2, bool throw_error = false)
{
	if (nummer2.länge == 0)
	{
		if (throw_error) //division durch 0
			assert(false);
		else
			return DivisionResultat(Nzahl(), Nzahl());
	}

	if (nummer1.länge == 0)
		return DivisionResultat(Nzahl(), Nzahl());

	else if (nummer1 == nummer2)
		return DivisionResultat(Nzahl([1]), Nzahl());

	else if (nummer2 > nummer1)
		return DivisionResultat(Nzahl(), Nzahl(nummer1));

	bool ist_ungerade = (nummer1.werte[0] % 2) != 0;

	DivisionResultat dr = dividiere(int_div_by2(nummer1), nummer2);

	dr.quotient = dr.quotient * Nzahl([2]);
	dr.rest = dr.rest * Nzahl([2]);

	if (ist_ungerade)
		dr.rest = dr.rest + Nzahl([1]);

	while (dr.rest >= nummer2)
	{
		dr.rest = dr.rest - nummer2;
		dr.quotient = dr.quotient + Nzahl([1]);
	}

	return dr;
}
