module tests.zahl.helfer;

import zahl.helfer;

import zahl.nzahl;

// @ {} [] # \ || != ~

unittest
{
  import std.stdio : write, writeln;

  writeln;
  writeln("    Testiere zahl.helfer");
  writeln("    ====================================");

  { //dup
    writeln("    dup(const ubyte* ptr, const ulong länge)");
    ubyte[] buffer = [0xAB, 0xCD, 0xEF, 0x00, 0x01];
    ubyte* new_ptr = dup(buffer.ptr, buffer.length);
    assert(new_ptr != null);

    ubyte[] buffer_copy = new_ptr[0 .. buffer.length];
    assert(buffer == buffer_copy);

    assert(dup(null, 0) == null);
  }
  {
    writeln("    reverse(Nzahl arr) (in place)");
    Nzahl test = Nzahl([0x00, 0xAB, 0xCD, 0xEF, 0x00, 0x01]);

    Nzahl umgekehrt = test.reverse();
    ubyte[] manuell_umgekehrt = [0x01, 0x00, 0xEF, 0xCD, 0xAB, 0x00];

    assert(umgekehrt.werte[0 .. umgekehrt.länge] == manuell_umgekehrt);
    assert(Nzahl() == Nzahl().reverse); //0 case
  }
  {
    writeln("    right_unpad(ref Nzahl num) (in place, per Nzahl konstruktor)");

    ubyte[] manuell_umgekehrt = [0x01, 0x00, 0xEF, 0xCD, 0xAB, 0x00];

    assert(Nzahl(manuell_umgekehrt) == Nzahl(manuell_umgekehrt[0 .. manuell_umgekehrt.length - 1]));
  }
  {
    writeln("    potenz(const Nzahl basis, const Nzahl exponent) (nur für convs momentan)");

    Nzahl test = Nzahl([0x00, 0xAB, 0xCD, 0xEF, 0x00, 0x01]);
    Nzahl texp = Nzahl([0x0A]);

    assert(potenz(test, texp) == Nzahl([
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x99, 0xA7, 0x8D, 0x6A, 0xAD, 0xAF, 0xDE, 0x85, 0x3F, 0xC5,
          0xDD, 0x86, 0xF5, 0xFC, 0xCE, 0xEE, 0x8D, 0x59, 0x11, 0x1A,
          0xDD, 0x65, 0x13, 0x33, 0x70, 0xA0, 0xC3, 0x2D, 0x98, 0xBD,
          0x03, 0x0A, 0x9A, 0xFF, 0xD1, 0xB7, 0x5D, 0xE8, 0x85, 0x09,
          0x01]));
  }
}
