module zahl.wandel;

import std.bigint : BigInt;
import std.bitmanip : littleEndianToNative;

import zahl.zahl : Zahl;
import zahl.gzahl : Gzahl;
import zahl.nzahl : Nzahl;
import zahl.bruch;

nothrow pure
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

/// Es nimmt die letzten vier ubytes und stopfft Sie in ein int.
/// Keine garantie, wie negative Zahlen funktionieren werden.
int als_int(const Nzahl liste, bool throw_on_overflow = true)
{
	if (liste.length > 4 && throw_on_overflow)
	{
		throw new Exception("Die Zahl ist zu gross für die Umwandlung in ein ubyte");
	}

	ubyte[4] kurze_liste;
	if (liste.länge > 4)
	{
		kurze_liste = liste.werte[$ - 4 .. $];
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

string als_string(Nzahl n)
{
	return als_string(n.werte);
}

string als_string(Gzahl g)
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
