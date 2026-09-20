module tests.zahl.zahl;

import zahl.zahl;
import zahl.gzahl;
import zahl.nzahl;
import zahl.bruch;

unittest
{
  import std.stdio : write, writeln;

  writeln;
  writeln("    Testiere zahl.zahl");
  writeln("    ====================================");

  {
    write("    Zahl, Grösse: ");
    writeln(Zahl.sizeof);
  }
  {
    writeln("    this / Konstruktoren");

    Gzahl gz = Gzahl([0x2C, 0x01], true);
    Nzahl nz = Nzahl([0x2C, 0x01]);
    Bruch br = Bruch([1], [2]);

    writeln("        Zahl(gz) == Zahl(nz) == Zahl(gz, br)");
    assert(Zahl(gz) == Zahl(nz));
    assert(Zahl(gz).vor_komma == gz);
    assert(Zahl(gz).nach_komma == Bruch());

    Zahl z_bruch = Zahl(gz, br);
    assert(z_bruch.vor_komma == gz);
    assert(z_bruch.nach_komma == br);

    Zahl z_copy = Zahl(z_bruch);
    assert(z_copy == z_bruch);

    writeln("        aufputzten von Brüchen");
    Bruch unecht = Bruch([5], [2]);
    Zahl z_norm = Zahl(gz, unecht);
    assert(z_norm.vor_komma == gz + Nzahl([2]));
    assert(z_norm.nach_komma == Bruch([1], [2]));
  }
  {
    writeln("    opCmp");

    Zahl eins_halb = Zahl(Nzahl([1]), Bruch([1], [2]));
    Zahl eins_viertel = Zahl(Nzahl([1]), Bruch([1], [4]));
    Zahl zwei = Zahl(Nzahl([2]));

    writeln("        1 1/4 < 1 1/2 < 2");
    assert(eins_viertel < eins_halb);
    assert(eins_halb < zwei);
    assert(eins_halb <= eins_halb);
    assert(zwei > eins_halb);
  }
  {
    //PLUS
    writeln("    opBinary");

    Zahl z1 = Zahl(Nzahl([2]), Bruch([1], [4]));
    Zahl z2 = Zahl(Nzahl([1]), Bruch([3], [4]));

    writeln("        2 1/4 + 1 3/4 = 4");
    assert(z1 + z2 == Zahl(Nzahl([4])));

    //MINUS
    writeln("        2 1/4 - 1 3/4 = 0 2/4 (mit Übertrag in nach_komma)");
    assert(z1 - z2 == Zahl(Nzahl([0]), Bruch([2], [4])));

    //MAL
    Zahl z3 = Zahl(Gzahl([2], true), Bruch([1], [2]));
    Zahl z4 = Zahl(Gzahl([3], true), Bruch([1], [3]));

    writeln("        MAL");
    assert(z3 * z4 == Zahl(Gzahl([8], true), Bruch([1], [3])));

    assert(
        Zahl(Gzahl([123], true), Bruch()) * Zahl(Gzahl(), Bruch([5], [10])) ==
        Zahl(Gzahl([61], true), Bruch([5], [10]))
        );

    writeln("        DURCH");
    Zahl z_div = Zahl(Gzahl([10], true)) / Zahl(Gzahl([2], true));
    assert(z_div.vor_komma == Gzahl([5], true));

    writeln("        Komp mit Gzahl und Nzahl");
    assert(z3 + Nzahl([1]) == Zahl(Nzahl([3]), Bruch([1], [2])));
    assert(z3 + Nzahl([1]) == Zahl(Nzahl([3]), Bruch([1], [2])));
  }
}
