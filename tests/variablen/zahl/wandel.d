module tests.zahl.wandel;

import zahl.wandel;

import std.exception : assertThrown;

import zahl.zahl;
import zahl.gzahl;
import zahl.nzahl;
import zahl.bruch;

unittest
{
  import std.stdio : write, writeln;

  writeln;
  writeln("    Testiere zahl.wandel");
  writeln("    ====================================");

  {
    writeln("    ist_zahl");
    assert(ist_zahl("123496876129348766123948761234987126349871234691234"d));
    assert(!ist_zahl(" f_111123"d));
    assert(!ist_zahl(""));
  }
  {
    writeln("    als_zahl");
    Zahl z1 = als_zahl("123"d);
    assert(z1.vor_komma.positiv == true);

    Zahl z2 = als_zahl("-123"d);
    assert(z2.positiv == false);

    Zahl z3 = als_zahl("12.34"d);
    assert(z3.positiv == true);
    assert(z3.nach_komma != Bruch());

    Zahl z4 = als_zahl("-12.34"d);
    assert(z4.positiv == false);

    assertThrown!Exception(als_zahl("12.34.56"d));
  }
  {
    writeln("    als_int");

    Nzahl n1 = Nzahl([0x05, 0x00, 0x00, 0x00]);
    assert(als_int(n1) == 5);

    Nzahl n2 = Nzahl([0x00, 0x01, 0x00, 0x00]);
    assert(als_int(n2) == 256);

    Nzahl nLarge = Nzahl([0x01, 0x02, 0x03, 0x04, 0x05]);
    assertThrown!Exception(als_int(nLarge, true));

    int res = als_int(nLarge, false);
    assert(res == cast(int)(0x02 | (0x03 << 8) | (0x04 << 16) | (0x05 << 24)));
  }
  {
    writeln("    als_string(ubyte[])");
    ubyte[] emptyArr;
    assert(als_string(emptyArr) == "0");
    assert(als_string([0x05]) == "5");
    assert(als_string([0xe8, 0x03]) == "1000");
  }
  {
    writeln("    als_string(Nzahl)");

    Nzahl n = Nzahl([0x05]);
    assert(als_string(n) == "5");
  }
  {
    writeln("    als_string(Gzahl)");

    Gzahl gPos = Gzahl([0x05], true);
    assert(als_string(gPos) == "5");

    Gzahl gNeg = Gzahl([0x05], false);
    assert(als_string(gNeg) == "-5");
  }{
    writeln("    als_string(Zahl)");

    Zahl zPos = als_zahl("123"d);
    assert(als_string(zPos) == "123");

    Zahl zNeg = als_zahl("-123.5"d);
    writeln(zNeg);
    writeln(als_string(zNeg));
    assert(als_string(zNeg) == "-123.5");
  }
  {
    writeln("    als_string(Bruch)");
    assert(als_string(Bruch([0x03], [0x04])) == "0.75");
    assert(als_string(Bruch([0x03], [0x06])) == "0.5");
    assert(als_string(Bruch([0x03], [0x05])) == "0.6");
  }
}
