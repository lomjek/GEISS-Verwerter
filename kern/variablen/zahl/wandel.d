module zahl.wandel;

import std.conv : to;
import std.array : split;
import std.range : retro;
import std.bigint : BigInt;
import std.math : trunc;
import std.bitmanip : nativeToLittleEndian, littleEndianToNative;

import zahl.zahl : Zahl;
import zahl.gzahl : Gzahl;
import zahl.nzahl : Nzahl;
import zahl.bruch;
import zahl.helfer;

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
  bool positiv = true;

  if (wort[0] == '-'){
    positiv = false;
    wort = wort[1 .. wort.length];
  }

  dstring[] parts = wort.split("."d);

  if (parts.length == 1)
    vor_komma_stellen = wort;

  else if (parts.length > 2)
    throw new Exception("Nur ein . pro Zahl ist möglich.");

  else
  {
    vor_komma_stellen = parts[0];
    nach_komma_stellen = parts[1];
  }

  ubyte[] vor_komma = als_zahl_us(vor_komma_stellen);

  Bruch bruch;

  if (nach_komma_stellen != "")
  {
    ubyte[] nach_komma = als_zahl_us(nach_komma_stellen);
    ubyte[] nach_komma_länge = als_zahl_uu(nach_komma_stellen.length);

    bruch = Bruch(Nzahl(nach_komma), Nzahl(potenz(Nzahl([10]), Nzahl(nach_komma_länge))));
  }

  return Zahl(Gzahl(vor_komma, positiv), bruch);
}

/// Es nimmt die letzten vier ubytes und stopfft Sie in ein int.
/// Keine garantie, wie negative Zahlen funktionieren werden.
int als_int(const Nzahl liste, bool throw_on_overflow = true)
{
  if (liste.länge > 4 && throw_on_overflow)
  {
    throw new Exception("Die Zahl ist zu gross für die Umwandlung in ein ubyte");
  }

  ubyte[4] kurze_liste = 0;

  if (liste.länge > 4)
  {
    kurze_liste[] = liste.werte[liste.länge - 4 .. liste.länge];
  }
  else if (liste.länge > 0 && liste.werte !is null)
  {
    kurze_liste[0 .. liste.länge] = liste.werte[0 .. liste.länge];
  }

  int resultat = cast(int) kurze_liste[0]
    | (cast(int) kurze_liste[1] << 8)
    | (
        cast(int) kurze_liste[2] << 16)
    | (cast(int) kurze_liste[3] << 24);

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
  return als_string(n.werte[0 .. n.länge]);
}

string als_string(Gzahl g)
{
  if (g.positiv == false)
    return "-" ~ als_string(Nzahl(g.grösse.werte, g.grösse.länge));
  else
    return als_string(Nzahl(g.grösse.werte, g.grösse.länge));
}

string als_string(const Zahl zahl)
{
  import std.stdio;

  Zahl z = Zahl(zahl);
  string result = "";

  if (z.vor_komma.positiv == false)
    result ~= "-";

  result ~= als_string(Nzahl(z.werte, z.länge));

  if (z.nach_komma.zähler.länge != 0 && z.nach_komma.nenner.länge != 0)
  {
    writeln("-");
    result ~= ".";
    result ~= als_string(z.nach_komma).split(".")[1];
  }

  return result;
}

  private pure nothrow @safe
ubyte[] floatToLittleEndianBytes(float value)
{
  ulong integerPart = (value >= cast(float) ulong.max) ? ulong.max : cast(ulong) trunc(value);

  size_t byteCount = 1;

  while (byteCount < ulong.sizeof &&
      (integerPart >> (byteCount * 8)) != 0)
  {
    ++byteCount;
  }

  ubyte[] result = new ubyte[byteCount];

  foreach (i; 0 .. byteCount)
  {
    result[i] = cast(ubyte)(integerPart >> (i * 8));
  }

  return result;
}

  private pure nothrow @safe
float littleEndianBytesToFloat(const(ubyte)[] bytes)
{
  ulong integerPart = 0;

  foreach (i, value; bytes)
  {
    if (i >= ulong.sizeof)
      break;

    integerPart |= cast(ulong) value << (i * 8);
  }

  return cast(float) integerPart;
}

string als_string(const Bruch b, size_t precision = 4)
{
  const Nzahl float_max = Nzahl(floatToLittleEndianBytes(float.max));

  Nzahl zähler = Nzahl(b.zähler);
  Nzahl nenner = Nzahl(b.nenner);

  size_t max_size = zähler.länge > nenner.länge ? zähler.länge : nenner.länge;

  zähler = right_pad(zähler, max_size);
  nenner = right_pad(nenner, max_size);

  if (max_size > precision)
  {
    zähler = Nzahl(zähler.werte[max_size - precision .. max_size]);
    nenner = Nzahl(nenner.werte[max_size - precision .. max_size]);
  }

  while (zähler > float_max || nenner > float_max)
  {
    zähler = zähler / Nzahl([0x00, 0x01]);
    nenner = nenner / Nzahl([0x00, 0x01]);
  }

  float oben = littleEndianBytesToFloat(zähler.werte[0 .. zähler.länge]);
  float unten = littleEndianBytesToFloat(nenner.werte[0 .. nenner.länge]);

  float resultat = oben / unten;

  return resultat.to!string;
}
