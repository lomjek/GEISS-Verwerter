module tests.ext.algorithm;

import ext.algorithm;

import zahl;

unittest
{
  import std.stdio : writeln, write;

  writeln;
  writeln("    Testiere ext.algorithm");
  writeln("    ====================================");

  { // random_zahl
    writeln("    random_zahl");

    // Identical limits
    Gzahl zehn = Gzahl([10], true);
    assert(random_zahl(zehn, zehn) == zehn);

    Gzahl minus_zehn = Gzahl([10], false);
    assert(random_zahl(minus_zehn, minus_zehn) == minus_zehn);

    // Range [1, 10]
    Gzahl eins = Gzahl([1], true);
    bool seen_different = false;
    Gzahl first_val = random_zahl(eins, zehn);

    foreach (i; 0 .. 100)
    {
      Gzahl r = random_zahl(eins, zehn);
      assert(r >= eins && r <= zehn);
      if (r != first_val)
        seen_different = true;
    }
    assert(seen_different);

    // Range swapped [10, 1]
    foreach (i; 0 .. 20)
    {
      Gzahl r = random_zahl(zehn, eins);
      assert(r >= eins && r <= zehn);
    }

    // Range with negative numbers [-10, 10]
    foreach (i; 0 .. 100)
    {
      Gzahl r = random_zahl(minus_zehn, zehn);
      assert(r >= minus_zehn && r <= zehn);
    }

    // Multi-byte range [0, 1000] (0x03E8)
    Gzahl null_gz = Gzahl([], true);
    Gzahl tausend = Gzahl([0xE8, 0x03], true);
    foreach (i; 0 .. 100)
    {
      Gzahl r = random_zahl(null_gz, tausend);
      assert(r >= null_gz && r <= tausend);
    }
  }

}
