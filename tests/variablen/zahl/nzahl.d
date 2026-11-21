module tests.zahl.nzahl;

import zahl.nzahl;

// @ {} [] # \ || != ~

unittest
{
	import std.stdio : write, writeln;

	writeln;
	writeln("    Testiere zahl.nzahl");
	writeln("    ====================================");

	{ // Nzahl grösse
		write("    Nzahl, grösse: ");
		writeln(Nzahl.sizeof);
	}
	{ // this
		writeln("    this / konstruktor");

		ubyte[] arr = [0x2C, 0x01];
		writeln("        Nzahl(arr) == Nzahl(arr.ptr, arr.length) == Nzahl(Nzahl(arr))");
		assert(Nzahl(arr) == Nzahl(arr.ptr, arr.length) &&
				Nzahl(arr.ptr, arr.length) == Nzahl(Nzahl(arr)));

		ubyte[] arrb = [0x2C, 0x01, 0x00];
		writeln("        Nzahl(arr) == Nzahl(arr ~ 0x00) (right_unpad)");
		assert(Nzahl(arr) == Nzahl(arrb));

		writeln("        Nzahl(arr).werte != arr.ptr (dup)");
		assert(Nzahl(arr).werte != arr.ptr);

		writeln("        Nzahl(size_t)");
		assert(Nzahl(size_t(0)) == Nzahl([0x00]));
		assert(Nzahl(size_t(300)) == Nzahl([0x2C, 0x01]));
		assert(Nzahl(size_t(1000)) == Nzahl([0xE8, 0x03]));
	}
	{ // opCmp
		writeln("    opCmp");

		Nzahl three_hundred = Nzahl([0x2C, 0x01]);
		Nzahl tausend = Nzahl([0xE8, 0x03]);
		Nzahl sechs_hundert = Nzahl([0x58, 0x02]);

		writeln("        300 < 1000");
		assert(three_hundred < tausend);

		writeln("        600 <= 1000");
		assert(sechs_hundert <= tausend);

		writeln("        1000 >= 1000");
		assert(tausend >= Nzahl(tausend));
	}
	{ // opBinary
		writeln("    opBinary");

		Nzahl ubyte_max = Nzahl([0xFF]);
		Nzahl eins = Nzahl([1]);
		Nzahl sechs_hundert = Nzahl([0x58, 0x02]);

		writeln("        1 + 255 = 256");
		assert(ubyte_max + eins == Nzahl([0x00, 0x01]));

		writeln("        600 - 255 = 345");
		assert(sechs_hundert - ubyte_max == Nzahl([0x59, 0x01]));

    writeln("        600 * 255 = 153000");
    assert(sechs_hundert * ubyte_max == Nzahl([0xA8, 0x55, 0x02]));

    writeln("        600 / 255 = 2 (int div)");
    assert(sechs_hundert  / ubyte_max == Nzahl([0x02]));
	}
}
