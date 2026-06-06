module zahl;

import std.algorithm : max, reverse;
import std.stdio : write;
import std.conv : to;

// @ {} [] # \ || != ~

struct Zahl
{
	bool negativ;
	ulong punkt_position;
	ubyte[] werte;
}

struct GanzeZahl
{
	bool negativ;
	ubyte[] werte;
}

struct NatürlicheZahl
{
	ubyte[] werte;
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

//MARK: ADDIERE
private ubyte[] addiere(ubyte[] a, ubyte[] b)
{
	// 
	if (a.length < b.length)
	{
		a = left_pad(a, b.length);
	}
	else if (b.length < a.length)
	{
		b = left_pad(b, a.length);
	}

	ubyte[] result = new ubyte[a.length];
	uint rest = 0;

	for (size_t i = a.length; i > 0; i--)
	{
		uint sum = a[i - 1] + b[i - 1] + rest;
		result[i - 1] = cast(ubyte)(sum & 0xFF);
		rest = sum >> 8;
	}

	if (rest > 0)
	{
		ubyte[] extendedResult = new ubyte[result.length + 1];
		extendedResult[0] = cast(ubyte) rest;
		extendedResult[1 .. $] = result;
		return extendedResult;
	}

	return result;
}

Zahl addiere(Zahl x, Zahl y)
{
	if (x.punkt_position == y.punkt_position)
	{
		GanzeZahl z = addiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte));
		return Zahl(z.negativ, x.punkt_position, z.werte);
	}

	ulong segments_after_dot_x = x.werte.length - x.punkt_position;
	ulong segments_after_dot_y = y.werte.length - y.punkt_position;
	x.werte = right_pad(x.werte, x.punkt_position + segments_after_dot_y);
	y.werte = right_pad(y.werte, y.punkt_position + segments_after_dot_x);

	GanzeZahl z = addiere(GanzeZahl(x.negativ, x.werte), GanzeZahl(y.negativ, y.werte));
	return Zahl(z.negativ, x.punkt_position, z.werte);
}

GanzeZahl addiere(GanzeZahl x, GanzeZahl y)
{
	if (x.negativ && y.negativ)
	{
		return GanzeZahl(true, addiere(x.werte, y.werte));
	}
	else if (x.negativ == false && y.negativ == false)
	{
		return GanzeZahl(false, addiere(x.werte, y.werte));
	}

	throw new Error("Not implemented");
}

NatürlicheZahl addiere(NatürlicheZahl x, NatürlicheZahl y)
{
	return NatürlicheZahl(addiere(x.werte, y.werte));
}

//MARK: SUBTRAHIERE
GanzeZahl subtrahiere(GanzeZahl x, GanzeZahl y)
{
	if (x.negativ != y.negativ)
	{
		return GanzeZahl(true, addiere(x.werte, y.werte));
	}

	ulong len = max(x.werte.length, y.werte.length);
	ubyte[] xPad = left_pad(x.werte, len);
	ubyte[] yPad = left_pad(y.werte, len);

	int compare = 0;
	for (ulong i = 0; i < len; i++)
	{
		if (xPad[i] < yPad[i])
		{
			compare = -1;
			break;
		}
		if (xPad[i] > yPad[i])
		{
			compare = 1;
			break;
		}
	}

	if (compare == 0)
	{
		return GanzeZahl(false, [0]); // Wenn die Zahlen gleich sind
	}

	ubyte[] a = compare > 0 ? xPad : yPad;
	ubyte[] b = compare > 0 ? yPad : xPad;
	bool resNegativ = compare > 0 ? x.negativ : !x.negativ;

	ubyte[] result = new ubyte[len];
	uint borrow = 0;

	for (long i = len - 1; i >= 0; i--)
	{
		int diff = a[i] - b[i] - borrow;
		if (diff < 0)
		{
			diff += 256;
			borrow = 1;
		}
		else
		{
			borrow = 0;
		}
		result[i] = cast(ubyte) diff;
	}

	size_t start = 0;
	while (start < result.length && result[start] == 0)
	{
		start++;
	}
	result = result[start .. $];

	if (result.length == 0)
	{
		result = [0];
	}

	return GanzeZahl(resNegativ, result);
}

GanzeZahl subtrahiere(NatürlicheZahl x, NatürlicheZahl y)
{
	return subtrahiere(GanzeZahl(false, x.werte), GanzeZahl(false, y.werte));
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
	return "-" ~ als_string(NatürlicheZahl(g.werte));
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
