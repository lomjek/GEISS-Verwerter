module zahl;

import ext.prints;
import variablen.wert;

import std.algorithm : max, remove;
import std.algorithm.mutation : reverse;
import std.stdio : write, writeln;
import std.conv : to;

// @ {} [] # \ || != ~

struct Zahl
{
	bool negativ;
	ulong punkt_position;
	ubyte[] werte;

	this(Zahl z)
	{
		this.negativ = z.negativ;
		this.punkt_position = z.punkt_position;
		this.werte = z.werte;
	}

	this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.punkt_position = gz.werte.length;
		this.werte = gz.werte;
	}

	this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.punkt_position = nz.werte.length;
		this.werte = nz.werte;
	}

	this(bool negativ, ulong punkt_position, ubyte[] werte)
	{
		this.negativ = negativ;
		this.punkt_position = punkt_position;
		this.werte = werte;
	}
}

struct GanzeZahl
{
	bool negativ;
	ubyte[] werte;

	this(NatürlicheZahl nz)
	{
		this.negativ = false;
		this.werte = nz.werte;
	}

	this(GanzeZahl gz)
	{
		this.negativ = gz.negativ;
		this.werte = gz.werte;
	}

	this(bool negativ, ubyte[] werte)
	{
		this.negativ = negativ;
		this.werte = werte;
	}
}

struct NatürlicheZahl
{
	ubyte[] werte;

	this(NatürlicheZahl nz)
	{
		this.werte = nz.werte;
	}

	this(ubyte[] werte)
	{
		this.werte = werte;
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

//MARK: COMPARE
bool is_bigger(ubyte[] x, ubyte[] y) // x > y => TRUE
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

bool is_equal(ubyte[] x, ubyte[] y)
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

//MARK: ADDIERE
private ubyte[] addiere(ubyte[] num1, ubyte[] num2, bool invert = true)
{
	if (invert)
	{
		num1 = reverse(left_pad(num1, num2.length)); // Pad and reverse ubyte array.
		num2 = reverse(left_pad(num2, num1.length));
	}
	else
	{
		num1 = num1.right_pad(num2.length);
		num2 = num2.right_pad(num1.length);
	}

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

	if (invert)
		return resultat.reverse;
	else
		return resultat;
}

Zahl addiere(Zahl x, Zahl y)
{
	ulong segments_after_dot_x = x.werte.length - x.punkt_position;
	ulong segments_after_dot_y = y.werte.length - y.punkt_position;

	if (segments_after_dot_x == segments_after_dot_y)
	{
		GanzeZahl z = addiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte));
		return Zahl(z.negativ, x.punkt_position, z.werte);
	}

	x.werte = right_pad(x.werte, x.punkt_position + segments_after_dot_y);
	y.werte = right_pad(y.werte, y.punkt_position + segments_after_dot_x);

	GanzeZahl z = addiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte));
	ulong punkt_position = z.werte.length - max(segments_after_dot_x, segments_after_dot_y);
	return Zahl(z.negativ, punkt_position, z.werte);
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

	throw new Error("Wenn man hier anlangt, weiss ich echt nicht, was passiert ist...");
}

NatürlicheZahl addiere(NatürlicheZahl x, NatürlicheZahl y)
{
	return NatürlicheZahl(addiere(x.werte, y.werte));
}

//MARK: SUBTRAHIERE
Zahl subtrahiere(Zahl x, Zahl y) // x - y
{
	ulong segments_after_dot_x = x.werte.length - x.punkt_position;
	ulong segments_after_dot_y = y.werte.length - y.punkt_position;

	if (segments_after_dot_x == segments_after_dot_y)
	{
		GanzeZahl z = subtrahiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte));
		return Zahl(z.negativ, x.punkt_position, z.werte);
	}

	x.werte = right_pad(x.werte, x.punkt_position + segments_after_dot_y);
	y.werte = right_pad(y.werte, y.punkt_position + segments_after_dot_x);

	GanzeZahl z = subtrahiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte)); // x - y 
	ulong punkt_position = z.werte.length - max(segments_after_dot_x, segments_after_dot_y);
	return Zahl(z.negativ, punkt_position, z.werte);
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

	ubyte[] min = reverse(left_pad(minuend.werte, subtrahend.werte.length));
	ubyte[] sub = reverse(left_pad(subtrahend.werte, minuend.werte.length));

	if (is_equal(sub, min))
	{
		return GanzeZahl(false, [0]);
	}

	bool inverted = false;

	if (is_bigger(sub, min))
	{
		ubyte[] zwischenspeicher = sub;
		sub = min;
		min = zwischenspeicher;

		inverted = true;
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
			"Das carryover sollte null sein, weil ich es ja vorher sonst inverted habe: " ~ carry_over
				.to!string);

	return GanzeZahl(inverted, resultat.reverse);
}

GanzeZahl subtrahiere(NatürlicheZahl x, NatürlicheZahl y) // x - y
{
	return subtrahiere(GanzeZahl(x), GanzeZahl(y));
}

//MARK: MULTIPLIKATION
private ubyte[] multipliziere(ubyte[] num1, ubyte[] num2) //Funktioniert nur mit ganzzahlen, aber auch nicht mit allen...
{
	num1 = num1.reverse;
	num2 = num2.reverse;

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
		matrix[0] = addiere(matrix[0], matrix[1], false);
		matrix = matrix.remove(1);
	}

	return matrix[0].reverse;
}

Zahl multipliziere(Zahl x, Zahl y)
{
	throw new Exception("Not implemented...");
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

//MARK: API
bool ist_zahl(dstring wort)
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

	werte = werte.reverse();

	return NatürlicheZahl(werte);
}

Zahl konstruiere(GanzeZahl vor, NatürlicheZahl nach)
{
	return Zahl(vor.negativ, vor.werte.length, vor.werte ~ nach.werte);
}

Zahl konstruiere(NatürlicheZahl vor, NatürlicheZahl nach)
{
	return konstruiere(GanzeZahl(false, vor.werte), nach);
}

//MARK: als_string
string als_string(NatürlicheZahl n)
{
	if (n.werte.length == 0)
	{
		return "0";
	}

	ubyte[] digits;
	digits ~= 0;

	for (size_t i = 0; i < n.werte.length; i++)
	{
		uint rest = n.werte[i];
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

	result ~= als_string(NatürlicheZahl(z.werte[0 .. z.punkt_position]));
	result ~= ".";
	result ~= als_string(NatürlicheZahl(z.werte[z.punkt_position .. $]));

	return result;
}
