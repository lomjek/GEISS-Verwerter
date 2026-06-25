module zahl;

import ext.prints;
import variablen.wert;

import std.algorithm : max, remove;
import std.range : retro;
import std.algorithm.mutation : reverse;
import std.stdio : write, writeln;
import std.conv : to;

// @ {} [] # \ || != ~

struct Zahl
{
	bool negativ;
	ubyte[] werte;
	Bruch nach_komma;

	pure this(Zahl z)
	{
		this.negativ = z.negativ;
		this.nach_komma = z.nach_komma;
		this.werte = z.werte;
	}

	pure this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.werte = gz.werte;
	}

	pure this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.werte = nz.werte;
	}

	pure this(bool negativ, Bruch nach_komma, ubyte[] werte)
	{
		this.negativ = negativ;
		this.werte = werte;
		this.nach_komma = nach_komma;
	}
}

struct GanzeZahl
{
	bool negativ;
	ubyte[] werte;

	pure this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.werte = nz.werte;
	}

	pure this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.werte = gz.werte;
	}

	pure this(bool negativ, ubyte[] werte)
	{
		this.negativ = negativ;
		this.werte = werte;
	}
}

struct NatürlicheZahl
{
	ubyte[] werte;

	pure this(NatürlicheZahl nz)
	{
		this.werte = nz.werte;
	}

	pure this(ubyte[] werte)
	{
		this.werte = werte;
	}
}

struct Bruch
{
	ubyte[] zähler;
	ubyte[] nenner;

	pure this(ubyte[] nzähler, ubyte[] nnenner)
	{
		zähler = nzähler;
		nenner = nnenner;
	}

	pure this(Bruch bruch)
	{
		zähler = bruch.zähler;
		nenner = bruch.nenner;
	}

	pure this(NatürlicheZahl nz)
	{
		zähler = nz.werte;
		nenner = [1];
	}
}

//MARK: PADDING
private pure ubyte[] left_pad(ubyte[] num, ulong desired_length)
{
	if (num.length >= desired_length)
	{
		return num;
	}

	ubyte[] padded = new ubyte[desired_length];
	padded[desired_length - num.length .. $] = num;
	return padded;
}

private pure ubyte[] right_pad(ubyte[] num, ulong desired_length)
{
	if (num.length >= desired_length)
	{
		return num;
	}

	ubyte[] padded = new ubyte[desired_length];
	padded[0 .. num.length] = num;
	return padded;
}

private pure ubyte[] right_unpad(ubyte[] num)
{
	num.reverse();
	ubyte[] unpadded;

	bool encountered_int = false;

	foreach (ubyte key; num)
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
pure bool ist_grösser(ubyte[] x, ubyte[] y) // x > y => TRUE
{
	if (x.length < y.length)
	{
		return false;
	}

	if (x.length > y.length)
	{
		return true;
	}

	if (x[$ - 1] > y[$ - 1])
	{
		return true;
	}
	else
	{
		return false;
	}
}

pure bool is_equal(ubyte[] x, ubyte[] y)
{
	x = left_pad(x, y.length);
	y = left_pad(y, x.length);

	for (ulong i = 0; i < x.length; i++)
	{
		if (x[i] != y[i])
			return false;
	}
	return true;
}

pure bool ist_grösser_gleich_1(Bruch bruch)
{
	if (is_equal(bruch.nenner, bruch.zähler))
		return true;

	if (ist_grösser(bruch.zähler, bruch.nenner))
		return true;

	return false;
}

pure private bool ist_grösser(Bruch num1, Bruch num2)
{
	ubyte[] zähler1 = multipliziere(num1.zähler, num2.nenner);
	ubyte[] zähler2 = multipliziere(num2.zähler, num1.nenner);

	return ist_grösser(zähler1, zähler2);
}

//MARK: ADDIERE
pure private ubyte[] addiere(ubyte[] num1, ubyte[] num2)
{
	num1 = right_pad(num1, num2.length); // Pad ubyte array.
	num2 = right_pad(num2, num1.length);

	ubyte[] resultat;
	ubyte überschuss = 0;

	if (num1.length != num2.length)
		throw new Error(
			"Es sollte nie passieren. Beim addieren von zwei Zahlen wurden sie nicht richtig gepaddet.");

	for (ulong i = 0; i < num1.length; i++)
	{
		ushort summe = num1[i] + num2[i] + überschuss;
		überschuss = cast(ubyte)(summe >> 8); //oberer Byte des ushort, was übertragen wird...
		resultat ~= cast(ubyte)(summe & 0xFF); // tieferer Byte des ushorts, was an der Stelle eingetragen wird.
	}

	if (überschuss)
		resultat ~= überschuss;

	return resultat;
}

pure private Bruch addiere(Bruch num1, Bruch num2)
{
	ubyte[] neuer_nenner = multipliziere(num1.nenner, num2.nenner);

	ubyte[] summand1 = multipliziere(num1.zähler, num2.nenner);
	ubyte[] summand2 = multipliziere(num2.zähler, num1.nenner);

	return Bruch(addiere(summand1, summand2), neuer_nenner);
}

pure Zahl addiere(Zahl x, Zahl y)
{
	if ((x.negativ && y.negativ) ||
		(!x.negativ && !y.negativ))
	{
		Bruch neuer_bruch = addiere(x.nach_komma, y.nach_komma);

		ubyte[] neuer_vor_komma_wert = addiere(x.werte, y.werte);

		while (neuer_bruch.ist_grösser_gleich_1)
		{
			neuer_vor_komma_wert = neuer_vor_komma_wert.addiere([1]);
			neuer_bruch = Bruch(subtrahiere(neuer_bruch.zähler, neuer_bruch.nenner), neuer_bruch
					.nenner);
		}

		return Zahl(x.negativ, neuer_bruch, neuer_vor_komma_wert);
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

pure GanzeZahl addiere(GanzeZahl num1, GanzeZahl num2)
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

pure NatürlicheZahl addiere(NatürlicheZahl x, NatürlicheZahl y)
{
	return NatürlicheZahl(addiere(x.werte, y.werte));
}

//MARK: SUBTRAHIERE
private pure ubyte[] subtrahiere(ubyte[] num1, ubyte[] num2)
{
	if (num2.ist_grösser(num1))
	{
		throw new Exception("Es gäbe einen Underflow");
	}

	ubyte[] min = right_pad(num1, num2.length);
	ubyte[] sub = right_pad(num2, num1.length);

	if (is_equal(sub, min))
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
		throw new Exception(
			"Es gibt ein Underflow von: " ~ carry_over
				.to!string);

	return resultat;
}

private pure Bruch subtrahiere(Bruch num1, Bruch num2)
{
	ubyte[] neuer_nenner = multipliziere(num1.nenner, num2.nenner);

	ubyte[] summand1 = multipliziere(num1.zähler, num2.nenner);
	ubyte[] summand2 = multipliziere(num2.zähler, num1.nenner);

	ubyte[] neuer_zähler = subtrahiere(summand1, summand2);

	return Bruch(neuer_zähler, neuer_nenner);
}

pure Zahl subtrahiere(Zahl minuend, Zahl subtrahend) // x - y
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

	if (ist_grösser(sub, min))
	{
		ubyte[] zwischenspeicher = sub;
		sub = min;
		min = zwischenspeicher;

		inverted = true;
	}

	ubyte[] sub_vor = subtrahiere(min, sub);
	Bruch sub_nach;
	if (inverted)
	{
		sub_nach = subtrahiere(subtrahend.nach_komma, minuend.nach_komma);
	}
	else
	{
		sub_nach = subtrahiere(minuend.nach_komma, subtrahend.nach_komma);
	}

	return Zahl(inverted, sub_nach, sub_vor);
}

pure GanzeZahl subtrahiere(GanzeZahl minuend, GanzeZahl subtrahend) // x - y 
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

	if (ist_grösser(sub, min))
	{
		ubyte[] zwischenspeicher = sub;
		sub = min;
		min = zwischenspeicher;

		inverted = true;
	}

	return GanzeZahl(inverted, subtrahiere(min, sub));
}

pure GanzeZahl subtrahiere(NatürlicheZahl x, NatürlicheZahl y) // x - y
{
	return subtrahiere(GanzeZahl(x), GanzeZahl(y));
}

//MARK: MULTIPLIKATION
pure private ubyte[] multipliziere(ubyte[] num1, ubyte[] num2) //Funktioniert nur mit ganzzahlen, aber auch nicht mit allen...
{
	ubyte[][] matrix;

	for (ulong i = 0; i < num2.length; i++)
	{
		ubyte[] zwischenresultat = [];
		ubyte überschuss = 0;

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

		ulong repeat = i;
		while (repeat != 0)
		{
			zwischenresultat = 0 ~ zwischenresultat;
			repeat--;
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

pure private Bruch multipliziere(Bruch num1, Bruch num2)
{
	return Bruch(multipliziere(num1.zähler, num2.zähler), multipliziere(num1.nenner, num1
			.zähler));
}

pure Zahl multipliziere(Zahl num1, Zahl num2)
{
	bool negativ = true;
	if ((num1.negativ && num2.negativ) ||
		(num1.negativ == false && num2.negativ == false))
		negativ = false;

	Bruch neuer_bruch = multipliziere(num1.nach_komma, num2.nach_komma);

	ubyte[] neuer_vor_komma_wert = multipliziere(num1.werte, num2.werte);

	while (neuer_bruch.ist_grösser_gleich_1)
	{
		neuer_vor_komma_wert = neuer_vor_komma_wert.addiere([1]);
		neuer_bruch = Bruch(
			subtrahiere(neuer_bruch.zähler, neuer_bruch.nenner), neuer_bruch
				.nenner);
	}

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
pure Bruch dividiere(Bruch num1, Bruch num2)
{
	return Bruch(multipliziere(num1.zähler, num2.nenner), multipliziere(num1.nenner, num2
			.zähler));
}

/// dividiere => ubyte[] / ubyte[] = ubyte[];
/// der Rest wird einfach weggeschmissen.
/// 0en am Anfang werden nicht weggestrichen.
pure ubyte[] dividiere(ubyte[] num1, ubyte[] num2)
{
	if (num2.right_unpad.length == 0)
		throw new Exception("Division durch 0");

	num1.reverse();

	ubyte byte1 = num1[0];
	ubyte byte2 = num1[1];

	ushort longer = cast(ushort)((byte1 << 8) | byte2);

	throw new Error("Not implemented");
}

pure Zahl dividiere(Zahl num1, Zahl num2);

//MARK: API
pure bool ist_zahl(dstring wort)
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

NatürlicheZahl als_zahl(dstring wort)
{
	if (!ist_zahl(wort))
		throw new Exception(
			"Es sollte nichts zu einer Zahl gemacht werden, was keine ist: " ~ cast(string) wort);

	ubyte[] digits;
	foreach (c; wort)
	{
		if (c >= '0' && c <= '9')
		{
			digits ~= cast(ubyte)(c - '0');
		}
		// Hier müsste ich, wenn ich wollen würde 0x und ähnliches Implementieren.
	}

	if (digits.length == 0)
	{
		return NatürlicheZahl([0]);
	}

	ubyte[] werte;
	while (digits.length > 0)
	{
		ubyte[] nextDigits;
		uint rest = 0;

		foreach (d; digits)
		{
			uint val = rest * 10 + d;
			uint q = val / 256;
			rest = val % 256;

			if (nextDigits.length > 0 || q > 0)
			{
				nextDigits ~= cast(ubyte) q;
			}
		}

		werte ~= cast(ubyte) rest;
		digits = nextDigits;
	}

	return NatürlicheZahl(werte);
}

Zahl konstruiere(GanzeZahl vor, NatürlicheZahl nach)
{
	//TODO:Implementieren
	throw new Error("Nicht implementiert.");
}

Zahl konstruiere(NatürlicheZahl vor, NatürlicheZahl nach)
{
	return konstruiere(GanzeZahl(false, vor.werte), nach);
}

//MARK: als_string
string als_string(NatürlicheZahl n)
{
	ubyte[] werte = n.werte;

	if (werte.length == 0)
	{
		return "0";
	}

	ubyte[] digits;
	digits ~= 0;

	foreach (uint rest; werte.retro)
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

string als_string(GanzeZahl g)
{
	if (g.negativ)
		return "-" ~ als_string(NatürlicheZahl(g.werte));
	else
		return als_string(NatürlicheZahl(g.werte));
}

string als_string(Zahl z)
{
	string result = "";

	if (z.negativ)
		result ~= "-";

	result ~= als_string(NatürlicheZahl(z.werte));
	result ~= ".";
	result ~= ""; // Man muss noch Zahl.toString machen.

	return result;
}

string als_string(Bruch b)
{
	return "bruch";
}
