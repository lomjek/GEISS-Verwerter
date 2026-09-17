module tests.variablen.zahl.nzahl;

import zahl.division;

import zahl.nzahl;

// @ {} [] # \ || != ~

unittest
{
	import std.stdio : write, writeln;

	writeln;
	writeln("    Testiere zahl.division");
	writeln("    ====================================");

  {
    write("    DivisionResultat, Grösse: ");
    writeln(DivisionResultat.sizeof);
  }
  { // int_div_by2
    writeln("    int_div_by2");

    writeln("        0 -> 0");
    assert(int_div_by2(Nzahl([0])) == Nzahl([0]));

    writeln("        300 -> 150");
    assert(int_div_by2(Nzahl([0x2C, 0x01])) == Nzahl([0x96]));

    writeln("        601 -> 300");
    assert(int_div_by2(Nzahl([0x59, 0x02])) == Nzahl([0x2C, 0x01]));
  }
  { // dividiere
    writeln("    dividiere");

    writeln("        10 / 0 -> 0, 0");
    assert(dividiere(Nzahl([0xA]), Nzahl()) == DivisionResultat(Nzahl(), Nzahl()));

    writeln("        0 / 5 -> 0, 0");
    assert(dividiere(Nzahl(), Nzahl([0x05])) == DivisionResultat(Nzahl(), Nzahl()));

    writeln("        42 / 42 -> 1, 0");
    assert(dividiere(Nzahl([0x2A]), Nzahl([0x2A])) == DivisionResultat(Nzahl([0x01]), Nzahl()));

    writeln("        9001 / 60 -> 150, 1");
    assert(dividiere(Nzahl([0x29, 0x23]), Nzahl([0x3C])) == DivisionResultat(Nzahl([0x96]), Nzahl([0x01])));
  }
}
