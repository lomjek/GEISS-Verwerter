module tests.zahl.gzahl;

import zahl.gzahl;

import zahl.nzahl;

// @ {} [] # \ || != ~

unittest
{
  import std.stdio : write, writeln;

  writeln;
  writeln("    Testiere zahl.gzahl");
  writeln("    ====================================");

  { // Gzahl grösse
    write("    Gzahl, Grösse: ");
    writeln(Gzahl.sizeof);
  }
  { // this
    writeln("    this / konstruktor");

    ubyte[] arr = [0x2C, 0x01];
    writeln("        Gzahl(arr, true) == Gzahl(arr.ptr, arr.length, true) == Gzahl(Nzahl(arr), true) == Gzahl(Gzahl(arr, true))");
    assert(Gzahl(arr, true) == Gzahl(arr.ptr, arr.length, true) &&
        Gzahl(Nzahl(arr.ptr, arr.length), true) == Gzahl(Gzahl(arr, true)) &&
        Gzahl(Gzahl(arr, true)) == Gzahl(arr, true));
  }
  { // opCmp
    writeln("    opCmp");

    Gzahl three_hundred_minus = Gzahl([0x2C, 0x01], false);
    Gzahl tausend = Gzahl([0xE8, 0x03], true);
    Gzahl sechs_hundert = Gzahl([0x58, 0x02], true);

    writeln("        -300 < 1000");
    assert(three_hundred_minus < tausend);

    writeln("        600 >= -1000");
    assert(sechs_hundert >= Gzahl(tausend.grösse, false));

    writeln("        -1000 <= 1000");
    assert(Gzahl(tausend.grösse, false) <= tausend);
  }
  { // opBinary
    writeln("    opBinary");

    Gzahl ubyte_max_neg = Gzahl([0xFF], false);
    Gzahl eins = Nzahl([1]);
    Gzahl sechs_hundert = Nzahl([0x58, 0x02]);

    //PLUS
    writeln("        1 + (-255) = -254");
    assert(ubyte_max_neg + eins == Gzahl([0xFE], false));

    writeln("        -600 + (-255) = -855");
    assert(Gzahl(sechs_hundert.grösse, false) + ubyte_max_neg == Gzahl([
        0x57, 0x03
      ], false));

    writeln("        -255 + 600 = 345");
    assert(ubyte_max_neg + sechs_hundert == Gzahl([0x59, 0x01], true));

    //MINUS
    writeln("        1 - 255 = -254");
    assert(eins - Gzahl([0xFF], true) == Gzahl([0xFE], false));

    writeln("        255 - 1 = 254");
    assert(Gzahl([0xFF], true) - eins == Gzahl([0xFE], true));

    writeln("        1 - (-255) = 256");
    assert(eins - ubyte_max_neg == Gzahl([0x00, 0x01], true));

    writeln("        -255 - 1 = -256");
    assert(ubyte_max_neg - eins == Gzahl([0x00, 0x01], false));

    //MAL
    writeln("        -255 * 600 = -153000");
    assert(ubyte_max_neg * sechs_hundert == Gzahl(cast(ubyte[])[
          0xA8, 0x55, 0x02
        ], false));

    writeln("        1 * (-255) = -255");
    assert(eins * ubyte_max_neg == Gzahl([0xFF], false));

    writeln("        -255 * (-255) = 65025");
    assert(ubyte_max_neg * ubyte_max_neg == Gzahl([0x01, 0xFE], true));

    writeln("        600 * 1 = 600");
    assert(sechs_hundert * eins == Gzahl([0x58, 0x02], true));

    //DIVISION
    writeln("        -153000 / -255 = 600");
    assert(Gzahl([0xA8, 0x55, 0x02], false) / ubyte_max_neg == sechs_hundert);

    writeln("        600 / (-255) = -2");
    assert(sechs_hundert / ubyte_max_neg == Gzahl([0x02], false));

    writeln("        -255 / 600 = 0");
    assert(ubyte_max_neg / sechs_hundert == Gzahl([0x00], true));

    writeln("        600 / 1 = 600");
    assert(sechs_hundert / eins == sechs_hundert);
  }
}
