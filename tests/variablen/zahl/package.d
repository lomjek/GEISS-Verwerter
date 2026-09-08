module ut_zahl;

import zahl;
import zahl.division;
import std.stdio : write, writeln;

unittest
{
	writeln("========================================");
	writeln("Testiere alle Zahlen");
	writeln("========================================");

	Bruch b_drittel = Bruch([1], [3]);
	Bruch b_viertel = Bruch([1], [4]);
	Nzahl drei = Nzahl([3]);

	write("Testiere ist_grösser(Bruch)... ");
	assert(b_drittel > b_viertel);
	assert(b_drittel >= b_viertel);
	writeln("läuft");

	write("Testiere addiere(Bruch)... ");
	assert((b_drittel + b_viertel) == Bruch([7], [12]));
	writeln("läuft");

	write("Testiere addiere(Zahl with fractions)... ");
	Zahl z_drittel = Zahl(Gzahl([0], true), b_drittel);
	Zahl z_viertel = Zahl(Gzahl([0], true), b_viertel);
	assert((z_drittel + z_viertel) == Zahl(Gzahl([0], true), Bruch([7], [12])));

	Zahl z_zwei_drittel = Zahl(Gzahl([0], true), Bruch([2], [3]));
	assert((z_zwei_drittel + z_zwei_drittel) ==
			Zahl(Gzahl([1], true), Bruch([3], [9])));
	writeln("läuft");

	write("Testiere Subtraktion...");
	{
		Zahl z1 = als_zahl("5.5"d);
		Zahl z2 = als_zahl("2.25"d);

		Zahl res = z1 - z2;
		assert(res == Zahl(Gzahl([3], true), Bruch([], [])));
	}
	{
		Zahl z1 = als_zahl("1.5"d);
		Zahl z2 = als_zahl("4.25"d);

		Zahl res = z1 - z2;
		assert(res == Zahl(Gzahl([3], true), Bruch([], [])));
	}
	writeln("läuft");

	write("Testiere als_zahl(\"3\")... ");
	assert(als_zahl("3") == Zahl(Nzahl([3])));
	writeln("läuft");

	write("Testiere int_div_by2([0x2C, 1])... ");
	assert(int_div_by2(Nzahl([0x2C, 1])) == Nzahl([150]));
	writeln("läuft");

	write("Testiere dividiere([4], [3]])... ");
	assert(dividiere(Nzahl([4]), Nzahl([3])) ==
			DivisionResultat(Nzahl([1]), Nzahl([1])));
	writeln("läuft");

	write("Testiere dividiere([4, 0x2C], [3])... ");
	assert(dividiere(Nzahl([4, 0x2C]), Nzahl([3])) ==
			DivisionResultat(Nzahl([0xAC, 0xE]), Nzahl([0])));
	writeln("läuft");

	write("Testiere dividiere(b_drittel, b_viertel)... ");
	assert(b_drittel / b_viertel == Bruch([4], [3]));
	writeln("läuft");

	write("Testiere dividiere(drei, Nzahl([2]))... ");
	assert(
		(Zahl(drei) / Nzahl([2])) == Zahl(
			Gzahl([1], true),
			Bruch([1], [2])
	)
	);
	writeln("läuft");

	write("Testiere dividiere(Zahl 3000, Zahl 2000)... ");
	assert((Zahl(Gzahl([0xB8, 0x0B], true), Bruch()) /
			Zahl(Gzahl([0xD0, 0x07], true), Bruch())) ==
			Zahl(
				Gzahl([1], true),
				Bruch([0xE8, 0x03], [0xD0, 0x07])
			)
	);
	writeln("läuft");

	writeln("========================================");
	writeln("All Zahlenoperationen funktionieren!");
	writeln("========================================");
	writeln;
}
