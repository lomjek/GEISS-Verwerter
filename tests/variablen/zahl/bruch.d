module tests.zahl.bruch;

import zahl.bruch;

import zahl.nzahl;

// @ {} [] # \ || != ~

unittest
{
  import std.stdio : write, writeln;

	writeln;
	writeln("    Testiere zahl.bruch");
	writeln("    ====================================");

  {
    write("    Bruch, Grösse: ");
    writeln(Bruch.sizeof);
  }
  {//this /konstruktor
    writeln("    this / konstruktor");

    ubyte[] arr = [0x2C, 0x01];
    ubyte[] arrb = [0x5D, 0x03];
    writeln("        Bruch(arr,  arrb) == Bruch(Nzahl(arr), Nzahl(arrb)) == Bruch(Bruch(arr, arrb))");
    assert(Bruch(arr, arrb) == Bruch(Nzahl(arr), Nzahl(arrb)) &&
        Bruch(arr, arrb) == Bruch(Bruch(arr, arrb)));
  }
  { // opCmp
    writeln("    opCmp");

    Bruch neun_sechstel_ = Bruch([0x09], [0x06]);
    Bruch sechs_neuntel_ = Bruch([0x06], [0x09]);

    ubyte[] arr = [0x2C, 0x01];
    ubyte[] arrb = [0x5D, 0x03];

    writeln("        (6/9) < (9/6)");
    assert(sechs_neuntel_ < neun_sechstel_);

    writeln("        (6/9) >= (6/9)");
    assert(sechs_neuntel_ >= sechs_neuntel_);

    writeln("        (861/300) > (9/6)");
    assert(Bruch(arrb, arr) > neun_sechstel_);
  }
  { //opBinary
    writeln("    opBinary");
    
    Bruch neun_sechstel = Bruch([0x09], [0x06]);
    Bruch sechs_neuntel = Bruch([0x06], [0x09]);
    Bruch sechs_3hundertstel = Bruch([0x06], [0x2C, 0x01]);

    writeln("        (9/6) + (6/300) = (2736/1800)");
    assert(neun_sechstel + sechs_3hundertstel == Bruch([0xB0, 0x0A], [0x08, 0x07]));

    writeln("        (9/6) - (6/300) = (2724/1800)");
    assert(neun_sechstel - sechs_3hundertstel == Bruch([0x68,  0x0A], [0x08, 0x07]));

    writeln("        (6/9) * (6/300) = (36/2700)");
    assert(sechs_neuntel * sechs_3hundertstel == Bruch([0x24], [0x8C, 0x0A]));

    writeln("        (6/9) / (6/300) = (1800/54)");
    assert(sechs_neuntel / sechs_3hundertstel == Bruch([0x08, 0x07], [0x36]));
  }
}
