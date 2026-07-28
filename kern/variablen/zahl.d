module zahl;

import ext.prints;
import variablen.wert;

import std.algorithm : max, remove, canFind, find;
import std.range : retro, split;
import std.bigint : BigInt;
import std.algorithm.mutation : reverse;
import std.bitmanip : littleEndianToNative;
import std.conv : to;

// @ {} [] # \ || != ~

struct Zahl
{
	bool negativ;
	ubyte[] werte;
	Bruch nach_komma;

	this(Zahl z)
	{
		this(z.negativ, z.nach_komma, z.werte);
	}

	nothrow
	this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.werte = gz.werte;
	}

	nothrow
	this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.werte = nz.werte;
	}

	this(bool negativ, Bruch nach_komma, ubyte[] werte)
	{
		this.negativ = negativ;
		DivisionResultat dr = dividiere(nach_komma.zähler, nach_komma.nenner, false);

		this.werte = addiere(werte, dr.quotient);
		this.nach_komma = Bruch(dr.rest, nach_komma.nenner);

		if (this.nach_komma.zähler.ist_null)
			this.nach_komma.nenner = [];
	}

	int opCmp(const ref Zahl other) const
	{
		GanzeZahl g1 = GanzeZahl(this.negativ, this.werte);
		GanzeZahl g2 = GanzeZahl(other.negativ, other.werte);

		int integerCmp = g1.opCmp(g2);
		if (integerCmp != 0)
			return integerCmp;

		int fracCmp = this.nach_komma.opCmp(other.nach_komma);
		return this.negativ ? -fracCmp : fracCmp;
	}
}

struct GanzeZahl
{
	bool negativ;
	ubyte[] werte;

	nothrow this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.werte = nz.werte;
	}

	nothrow this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.werte = gz.werte;
	}

	nothrow this(const bool negativ, const ubyte[] werte)
	{
		this.negativ = negativ;
		this.werte = werte.dup;
	}

	int opCmp(const ref GanzeZahl other) const
	{
		ubyte[] num1 = right_unpad(this.werte.dup);
		ubyte[] num2 = right_unpad(other.werte.dup);

		if (num1.length == 0 && num2.length == 0)
			return 0;

		if (this.negativ != other.negativ)
			return this.negativ ? -1 : 1;

		int cmp = 0;
		if (num1.length != num2.length)
		{
			cmp = num1.length < num2.length ? -1 : 1;
		}
		else
		{
			foreach_reverse (i; 0 .. num1.length)
			{
				if (num1[i] != num2[i])
				{
					cmp = num1[i] < num2[i] ? -1 : 1;
					break;
				}
			}
		}

		return this.negativ ? -cmp : cmp;
	}
}

struct NatürlicheZahl
{
	ubyte[] werte;

	nothrow this(NatürlicheZahl nz)
	{
		this.werte = nz.werte;
	}

	nothrow this(ubyte[] werte)
	{
		this.werte = werte;
	}

	int opCmp(const NatürlicheZahl other) const
	{
		ubyte[] num1 = right_unpad(werte.dup);
		ubyte[] num2 = right_unpad(other.werte.dup);

		if (num1.length != num2.length)
			return num1.length < num2.length ? -1 : 1;

		foreach_reverse (i; 0 .. num1.length)
		{
			if (num1[i] != num2[i])
				return num1[i] < num2[i] ? -1 : 1;
		}

		return 0;
	}
}

struct Bruch
{
	ubyte[] zähler;
	ubyte[] nenner;

	nothrow
	this(ubyte[] nzähler, ubyte[] nnenner)
	{
		zähler = nzähler;
		nenner = nnenner;
	}

	nothrow
	this(Bruch bruch)
	{
		zähler = bruch.zähler;
		nenner = bruch.nenner;
	}

	int opCmp(const Bruch other) const
	{
		ubyte[] zähler1 = multipliziere(this.zähler, other.nenner);
		ubyte[] zähler2 = multipliziere(other.zähler, this.nenner);

		return NatürlicheZahl(zähler1).opCmp(NatürlicheZahl(zähler2));
	}
}

//MARK: PADDING
private ubyte[] left_pad(ubyte[] num, ulong desired_length)
{
	if (num.length >= desired_length)
	{
		return num;
	}

	ubyte[] padded = new ubyte[desired_length];
	padded[desired_length - num.length .. $] = num;
	return padded;
}

nothrow
private ubyte[] right_pad(ubyte[] num, ulong desired_length)
{
	if (num.length >= desired_length)
	{
		return num;
	}

	ubyte[] padded = new ubyte[desired_length];
	padded[0 .. num.length] = num;
	return padded;
}

nothrow
private ubyte[] right_pad(const ubyte[] num, ulong desired_length)
{
	return right_pad(num.dup, desired_length);
}

nothrow
private ubyte[] right_unpad(const ubyte[] num)
{
	ubyte[] arr = num.dup;
	arr.reverse();
	ubyte[] unpadded;

	bool encountered_int = false;

	foreach (ubyte key; arr)
	{
		if (encountered_int)
		{
			unpadded ~= key;
		}
		else if (key != 0)
		{
			encountered_int = true;
			unpadded ~= key;
		}
	}

	return unpadded.reverse;
}

//MARK: COMPARE
private bool ist_grösser_gleich_1(Bruch bruch)
{
	if (bruch.nenner.length == 0 && bruch.zähler.length == 0)
		return false;

	if (NatürlicheZahl(bruch.zähler) == NatürlicheZahl(bruch.nenner))
		return true;

	if (NatürlicheZahl(bruch.zähler) > NatürlicheZahl(bruch.nenner))
		return true;

	return false;
}

nothrow
private bool ist_null(const ubyte[] num)
{
	foreach (ubyte b; num)
	{
		if (b != 0)
			return false;
	}
	return true;
}

//MARK: ADDIERE
nothrow
private ubyte[] addiere(const ubyte[] nummer1, const ubyte[] nummer2)
{
	ulong max_len = nummer1.length > nummer2.length ? nummer1.length : nummer2.length;
	ubyte[] num1 = right_pad(nummer1, max_len);
	ubyte[] num2 = right_pad(nummer2, max_len);

	ubyte[] resultat;
	ubyte überschuss = 0;

	for (ulong i = 0; i < max_len; i++)
	{
		ushort summe = cast(ushort)(num1[i] + num2[i] + überschuss);
		überschuss = cast(ubyte)(summe >> 8);
		resultat ~= cast(ubyte)(summe & 0xFF);
	}

	if (überschuss)
		resultat ~= überschuss;

	return resultat;
}

nothrow
private Bruch addiere(Bruch num1, Bruch num2)
{
	if (num2.zähler.ist_null)
		return num1;

	else if (num1.zähler.ist_null)
		return num2;

	ubyte[] neuer_nenner = multipliziere(num1.nenner, num2.nenner);

	ubyte[] summand1 = multipliziere(num1.zähler, num2.nenner);
	ubyte[] summand2 = multipliziere(num2.zähler, num1.nenner);

	return Bruch(addiere(summand1, summand2), neuer_nenner);
}

Zahl addiere(Zahl num1, Zahl num2)
{
	if ((num1.negativ && num2.negativ) ||
		(!num1.negativ && !num2.negativ))
	{
		Bruch neuer_bruch = addiere(num1.nach_komma, num2.nach_komma);

		ubyte[] neuer_vor_komma_wert = addiere(num1.werte, num2.werte);

		while (neuer_bruch.ist_grösser_gleich_1)
		{
			neuer_vor_komma_wert = neuer_vor_komma_wert.addiere([1]);
			neuer_bruch = Bruch(subtrahiere(neuer_bruch.zähler, neuer_bruch.nenner), neuer_bruch
					.nenner);
		}

		return Zahl(num1.negativ, neuer_bruch, neuer_vor_komma_wert);
	}

	if (num1.negativ && num2.negativ == false)
	{
		return subtrahiere(num2, num1);
	}
	else if (num1.negativ == false && num2.negativ)
	{
		return subtrahiere(num1, num2);
	}

	//Man sollte hier nie anlangen...
	throw new Exception("Es sollte nie hier ankommen...");
}

GanzeZahl addiere(GanzeZahl num1, GanzeZahl num2)
{
	if (num1.negativ && num2.negativ)
	{
		return GanzeZahl(true, addiere(num1.werte, num2.werte));
	}
	else if (num1.negativ == false && num2.negativ == false)
	{
		return GanzeZahl(false, addiere(num1.werte, num2.werte));
	}

	if (num1.negativ && num2.negativ == false)
	{
		return subtrahiere(num2, num1);
	}
	else if (num1.negativ == false && num2.negativ)
	{
		return subtrahiere(num1, num2);
	}

	//Man sollte hier nie anlangen...
	throw new Exception("Es sollte nie hier ankommen...");
}

NatürlicheZahl addiere(NatürlicheZahl x, NatürlicheZahl y)
{
	return NatürlicheZahl(addiere(x.werte, y.werte));
}

//MARK: SUBTRAHIERE
private ubyte[] subtrahiere(const ubyte[] num1, const ubyte[] num2)
{
	if (NatürlicheZahl(num2.dup) > NatürlicheZahl(num1.dup))
	{
		throw new Exception("Es gäbe einen Underflow");
	}

	ubyte[] min = right_pad(num1.dup, num2.length);
	ubyte[] sub = right_pad(num2.dup, num1.length);

	if (NatürlicheZahl(min) == NatürlicheZahl(sub))
	{
		return [0];
	}

	ubyte[] resultat;

	ushort buffer;
	ubyte carry_over;
	for (ulong i = 0; i < sub.length; i++)
	{
		buffer = min[i];
		ushort subtr = cast(ushort)(sub[i] + carry_over);

		if (min[i] < subtr)
		{
			buffer += 0x100; // 0x100 ist die Erste Zahl die grösser ist, als der jetztige buffer;
			carry_over = 0x1;
		}
		else
		{
			carry_over = 0;
		}

		resultat ~= cast(ubyte)(buffer - subtr);
	}

	if (carry_over != 0)
		throw new Exception("Es gibt ein Underflow von: "
				~ carry_over.to!string ~ " : " ~ min.als_string ~ ", " ~ sub.als_string);

	return resultat;
}

private Bruch subtrahiere(Bruch num1, Bruch num2)
{
	if (num2 > num1)
		throw new Exception("Man kann nicht das grössere vom kleinern Subtrahieren");

	ubyte[] neuer_nenner = multipliziere(num1.nenner, num2.nenner);

	ubyte[] summand1 = multipliziere(num1.zähler, num2.nenner);
	ubyte[] summand2 = multipliziere(num2.zähler, num1.nenner);

	ubyte[] neuer_zähler = subtrahiere(summand1, summand2);

	return Bruch(neuer_zähler, neuer_nenner);
}

Zahl subtrahiere(Zahl minuend, Zahl subtrahend) // x - y
{
	if (minuend.negativ && subtrahend.negativ == false)
	{
		ubyte[] summe = addiere(minuend.werte, subtrahend.werte);
		Bruch summe_auch = addiere(minuend.nach_komma, subtrahend.nach_komma);
		return Zahl(true, summe_auch, summe);
	}
	else if (minuend.negativ == false && subtrahend.negativ)
	{
		ubyte[] summe_vor = addiere(minuend.werte, subtrahend.werte);
		Bruch summe_nach = addiere(minuend.nach_komma, subtrahend.nach_komma);
		return Zahl(false, summe_nach, summe_vor);
	}
	else if (minuend.negativ && subtrahend.negativ)
	{
		Zahl summe = addiere(minuend, Zahl(false, subtrahend.nach_komma, subtrahend.werte));
		return Zahl(false, summe.nach_komma, summe.werte);
	}

	bool inverted = false;

	ubyte[] min = minuend.werte;
	ubyte[] sub = subtrahend.werte;

	Bruch sub_nach;

	if (subtrahend.nach_komma > minuend.nach_komma)
	{
		sub_nach = subtrahiere(subtrahend.nach_komma, minuend.nach_komma);
		sub = addiere(sub, [1]);
	}

	if (NatürlicheZahl(sub) > NatürlicheZahl(min))
	{
		ubyte[] zwischenspeicher = sub;
		sub = min;
		min = zwischenspeicher;

		inverted = true;
	}

	ubyte[] sub_vor = subtrahiere(min, sub);

	return Zahl(inverted, sub_nach, sub_vor);
}

GanzeZahl subtrahiere(GanzeZahl minuend, GanzeZahl subtrahend) // x - y 
{
	if (minuend.negativ && subtrahend.negativ == false)
	{
		return GanzeZahl(true, addiere(minuend.werte, subtrahend.werte));
	}
	else if (minuend.negativ == false && subtrahend.negativ)
	{
		return GanzeZahl(false, addiere(minuend.werte, subtrahend.werte));
	}
	else if (minuend.negativ && subtrahend.negativ)
	{
		GanzeZahl summe = addiere(minuend, GanzeZahl(false, subtrahend.werte));
		return GanzeZahl(false, summe.werte);
	}

	bool inverted = false;

	ubyte[] min = minuend.werte;
	ubyte[] sub = subtrahend.werte;

	if (NatürlicheZahl(sub) > NatürlicheZahl(min))
	{
		ubyte[] zwischenspeicher = sub;
		sub = min;
		min = zwischenspeicher;

		inverted = true;
	}

	return GanzeZahl(inverted, subtrahiere(min, sub));
}

GanzeZahl subtrahiere(NatürlicheZahl x, NatürlicheZahl y) // x - y
{
	return subtrahiere(GanzeZahl(x), GanzeZahl(y));
}

//MARK: MULTIPLIKATION
nothrow
private ubyte[] multipliziere(const ubyte[] num1, const ubyte[] num2) //Funktioniert nur mit ganzzahlen, aber auch nicht mit allen...
{
	ubyte[][] matrix;

	if (num1.length == 0 || num2.length == 0)
		return [0];

	if ((num1.length == 1 && num1[0] == 0) || (num2.length == 1 && num2[0] == 0))
		return [0];

	if (num1.length == 0 || num2.length == 0)
		return [0];

	for (ulong i = 0; i < num2.length; i++)
	{
		ubyte[] zwischenresultat = [];
		ubyte überschuss = 0;

		ulong repeat = i;
		while (repeat != 0)
		{
			zwischenresultat ~= 0;
			repeat--;
		}

		for (ulong j = 0; j < num1.length; j++)
		{
			ushort ziffer = (num1[j] * num2[i]) + überschuss;
			überschuss = cast(ubyte)(ziffer >> 8); //oberer Byte des ushort, was übertragen wird...
			zwischenresultat ~= cast(ubyte)(ziffer & 0xFF); // tieferer Byte des ushorts, was an der Stelle eingetragen wird.
		}

		if (überschuss > 0)
		{
			zwischenresultat ~= überschuss;
		}

		matrix ~= zwischenresultat;
	}

	while (matrix.length > 1)
	{
		matrix[0] = addiere(matrix[0], matrix[1]);
		matrix = matrix.remove(1);
	}

	return matrix[0];
}

private Bruch multipliziere(Bruch num1, Bruch num2)
{
	return Bruch(multipliziere(num1.zähler, num2.zähler),
		multipliziere(num1.nenner, num2.zähler));
}

Zahl multipliziere(Zahl num1, Zahl num2)
{
	bool negativ = true;
	if ((num1.negativ && num2.negativ) ||
		(num1.negativ == false && num2.negativ == false))
		negativ = false;

	Bruch neuer_bruch = multipliziere(num1.nach_komma, num2.nach_komma);

	ubyte[] neuer_vor_komma_wert = multipliziere(num1.werte, num2.werte);

	return Zahl(negativ, neuer_bruch, neuer_vor_komma_wert);
}

GanzeZahl multipliziere(GanzeZahl num1, GanzeZahl num2)
{
	if ((num1.negativ && num2.negativ) ||
		(num1.negativ == false && num2.negativ == false))
		return GanzeZahl(false, multipliziere(num1.werte, num2.werte));

	return GanzeZahl(true, multipliziere(num1.werte, num2.werte));
}

NatürlicheZahl multipliziere(NatürlicheZahl num1, NatürlicheZahl num2)
{
	return NatürlicheZahl(multipliziere(num1.werte, num2.werte));
}

//MARK: DIVISON

/// dividiere => Bruch / Bruch = Bruch
/// Funktioniert eigentlich durch multiplikation.
nothrow Bruch dividiere(Bruch num1, Bruch num2)
{
	return Bruch(multipliziere(num1.zähler, num2.nenner), multipliziere(num1.nenner, num2
			.zähler));
}

struct DivisionResultat
{
	ubyte[] quotient;
	ubyte[] rest;
}

/// Essentiel ein grosser ByteShift nach Unten.

ubyte[] int_div_by2(const ubyte[] num)
{
	ubyte[] nummer = num.dup.reverse;

	bool übertragung = false;

	for (ulong i = 0; nummer.length > i; i++)
	{
		ubyte temp = nummer[i];

		nummer[i] = temp >> 1;

		if (übertragung)
			nummer[i] += 0b_1000_0000;

		übertragung = (temp % 2) != 0;
	}

	return reverse(nummer).right_unpad;
}

/// dividiere => ubyte[] / ubyte[] = DivisionResultat;
/// 0en am Anfang werden nicht weggestrichen.
/// Ich verstehe diesen Algorithmus nicht, aber er funktioniert.
/// => Fast recursive division
DivisionResultat dividiere(const ubyte[] nummer1, const ubyte[] nummer2, bool throw_error = true)
{
	if (nummer2.ist_null)
	{
		if (throw_error)
			throw new Exception("Division durch 0");
		else
			return DivisionResultat([], []);
	}

	ubyte[] num1 = nummer1.dup.right_unpad();
	ubyte[] num2 = nummer2.dup.right_unpad();

	if (num1 == [0] || num1.length == 0)
		return DivisionResultat([0], [0]);

	else if (num1 == num2)
		return DivisionResultat([1], [0]);

	else if (NatürlicheZahl(num2) > NatürlicheZahl(num1))
		return DivisionResultat([0], num1);

	bool ist_ungerade = (num1[0] % 2) != 0;

	DivisionResultat dr = dividiere(int_div_by2(num1), num2);

	dr.quotient = multipliziere(dr.quotient, [2]);
	dr.rest = multipliziere(dr.rest, [2]);

	if (ist_ungerade)
		dr.rest = addiere(dr.rest, [1]);

	while (NatürlicheZahl(dr.rest) >= NatürlicheZahl(num2))
	{
		dr.rest = subtrahiere(dr.rest, num2);
		dr.quotient = addiere(dr.quotient, [1]);
	}

	return dr;
}

Zahl dividiere(Zahl num1, Zahl num2)
{
	bool negativ = (num1.negativ != num2.negativ);

	// num1 als Bruch
	Bruch vor_komma1 = Bruch(num1.werte, [1]);
	Bruch bruch1 = addiere(vor_komma1, num1.nach_komma);

	// num2 als Bruch
	Bruch vor_komma2 = Bruch(num2.werte, [1]);
	Bruch bruch2 = addiere(vor_komma2, num2.nach_komma);

	Bruch resultat = dividiere(bruch1, bruch2);

	return Zahl(
		negativ,
		resultat,
		[]
	);
}

Zahl dividiere(GanzeZahl num1, GanzeZahl num2)
{
	DivisionResultat dr = dividiere(num1.werte, num2.werte);
	bool negativ = (num1.negativ != num2.negativ);

	return Zahl(
		negativ,
		Bruch(dr.rest, num2.werte),
		dr.quotient
	);
}

Zahl dividiere(NatürlicheZahl num1, NatürlicheZahl num2)
{
	DivisionResultat dr = dividiere(num1.werte, num2.werte);
	return Zahl(
		false,
		Bruch(dr.rest, num2.werte),
		dr.quotient
	);
}

//MARK: POTENTIERUNG

/// potenz => ubyte[] ^ ubyte[] = ubyte[];
/// die zweite Zahl wird kopiert...
ubyte[] potenz(ubyte[] num1, ubyte[] num2)
{
	while (NatürlicheZahl(num2) > NatürlicheZahl([1]))
	{
		num1 = num1.multipliziere(num1);
		num2 = subtrahiere(num2, [1]);
	}

	return num1;
}

//MARK: ist_zahl
nothrow bool ist_zahl(dstring wort)
{
	bool allDigits = wort.length > 0;

	foreach (dchar c; wort)
	{
		if (c < '0' || c > '9')
		{
			allDigits = false;
			break;
		}
		// Hier kann ich, wenn ich will für andere Zeichen überprüfen wie 4e10 'e'
	}

	return allDigits;
}
//MARK: als_zahl

/// ALS ZAHL str => ubyte[]
private ubyte[] als_zahl_us(dstring wort)
{
	BigInt bgi = BigInt(wort);
	return als_zahl_ub(bgi);
}

/// ALS ZAHL ulong => ubyte[]
private ubyte[] als_zahl_uu(ulong num)
{
	BigInt bgi = BigInt(num);
	return als_zahl_ub(bgi);
}

/// ALS ZAHL BigInt => ubyte[]
private ubyte[] als_zahl_ub(BigInt bgi)
{
	ubyte[] resultat;

	if (bgi == 0)
	{
		return [0];
	}

	while (bgi > 0)
	{
		resultat ~= to!ubyte(bgi % 256);
		bgi /= 256;
	}

	return resultat;
}

Zahl als_zahl(dstring wort)
{
	dstring vor_komma_stellen;
	dstring nach_komma_stellen;

	if (wort.canFind("."d))
	{
		dstring[] parts = wort.split("."d);

		if (parts.length > 2)
			throw new Exception("Nur ein . pro Zahl ist möglich.");

		vor_komma_stellen = parts[0];
		nach_komma_stellen = parts[1];
	}
	else
	{
		vor_komma_stellen = wort;
	}

	ubyte[] vor_komma = als_zahl_us(vor_komma_stellen);

	Bruch bruch;

	if (nach_komma_stellen != "")
	{
		ubyte[] nach_komma = als_zahl_us(nach_komma_stellen);
		ubyte[] nach_komma_länge = als_zahl_uu(nach_komma_stellen.length);

		bruch = Bruch(nach_komma, potenz([10], nach_komma_länge));
	}

	return Zahl(false, bruch, vor_komma);
}

//MARK: als_string
string als_string(ubyte[] num)
{
	if (num.length == 0)
	{
		return "0";
	}

	ubyte[] digits;
	digits ~= 0;

	foreach (uint rest; num.retro)
	{
		for (size_t j = 0; j < digits.length; j++)
		{
			uint prod = digits[j] * 256 + rest;
			digits[j] = cast(ubyte)(prod % 10);
			rest = prod / 10;
		}
		while (rest > 0)
		{
			digits ~= cast(ubyte)(rest % 10);
			rest /= 10;
		}
	}

	char[] result;
	result.length = digits.length;
	for (size_t i = 0; i < digits.length; i++)
	{
		result[i] = cast(char)('0' + digits[digits.length.to!long - 1 - i]);
	}

	return cast(string) result;
}

string als_string(NatürlicheZahl n)
{
	return als_string(n.werte);
}

string als_string(GanzeZahl g)
{
	if (g.negativ)
		return "-" ~ als_string(NatürlicheZahl(g.werte));
	else
		return als_string(NatürlicheZahl(g.werte));
}

string als_string(Zahl z)
{
	z = Zahl(z);
	string result = "";

	if (z.negativ)
		result ~= "-";

	result ~= als_string(NatürlicheZahl(z.werte));

	if (z.nach_komma != Bruch())
	{
		result ~= ".";
		result ~= als_string(z.nach_komma);
	}

	return result;
}

string als_string(Bruch b, ulong maxLen = 100)
{
	return "(" ~ b.zähler.als_string ~ " / " ~ b.nenner.als_string ~ ")";
}

//MARK: als_std_zahl

/// Es nimmt die letzten vier ubytes und stopfft Sie in ein int.
/// Keine garantie, wie negative Zahlen funktionieren werden.
int als_int(ubyte[] liste, bool throw_on_overflow = true)
{
	if (liste.length > 4 && throw_on_overflow)
	{
		throw new Exception("Die Zahl ist zu gross für die Umwandlung in ein ubyte");
	}

	ubyte[4] kurze_liste;
	if (liste.length > 4)
	{
		kurze_liste = liste[$ - 4 .. $];
	}
	else
	{
		while (liste.length < 4)
		{
			liste = liste ~ 0;
		}
		kurze_liste = liste;
	}

	int resultat = littleEndianToNative!int(kurze_liste);

	return resultat;
}
