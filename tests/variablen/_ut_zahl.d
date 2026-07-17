module ut_zahl;

import zahl;
import std.stdio : write, writeln;

unittest
{
	writeln("========================================");
	writeln("Testiere alle Zahlen");
	writeln("========================================");

	Bruch b_drittel = Bruch([1], [3]);
	Bruch b_viertel = Bruch([1], [4]);
	NatürlicheZahl drei = NatürlicheZahl([3]);

	write("Testiere ist_grösser(Bruch)... ");
	assert(ist_grösser(b_drittel, b_viertel));
	writeln("läuft");

	write("Testiere addiere(Bruch)... ");
	assert(addiere(b_drittel, b_viertel) == Bruch([7], [12]));
	writeln("läuft");

	write("Testiere addiere(Zahl with fractions)... ");
	Zahl z_drittel = Zahl(false, b_drittel, [0]);
	Zahl z_viertel = Zahl(false, b_viertel, [0]);
	assert(addiere(z_drittel, z_viertel) == Zahl(false, Bruch([7], [12]), [0]));

	Zahl z_zwei_drittel = Zahl(false, Bruch([2], [3]), [0]);
	assert(addiere(z_zwei_drittel, z_zwei_drittel) ==
			Zahl(false, Bruch([3], [9]), [1]));
	writeln("läuft");

	write("Testiere Subtraktion...");
	{
		Zahl z1 = als_zahl("5.5"d);
		Zahl z2 = als_zahl("2.25"d);

		Zahl res = subtrahiere(z1, z2);
		assert(res == Zahl(false, Bruch([], []), [3]));
	}
	{
		Zahl z1 = als_zahl("1.5"d);
		Zahl z2 = als_zahl("4.25"d);

		Zahl res = subtrahiere(z1, z2);
		assert(res == Zahl(true, Bruch([], []), [3]));
	}
	writeln("läuft");

	write("Testiere als_zahl(\"3\")... ");
	assert(als_zahl("3") == Zahl(NatürlicheZahl([3])));
	writeln("läuft");

	write("Testiere int_div_by2([0x2C, 1])... ");
	assert(int_div_by2([0x2C, 1]) == [150]);
	writeln("läuft");

	write("Testiere dividiere([4], [3]])... ");
	assert(dividiere([4], [3]) == DivisionResultat([1], [1]));
	writeln("läuft");

	write("Testiere dividiere([4, 0x2C], [3])... ");
	assert(dividiere([4, 0x2C], [3]) == DivisionResultat([0xAC, 0xE], [0]));
	writeln("läuft");

	write("Testiere dividiere(b_drittel, b_viertel)... ");
	assert(dividiere(b_drittel, b_viertel) == Bruch([4], [3]));
	writeln("läuft");

	write("Testiere dividiere(drei, NatürlicheZahl([2]))... ");
	assert(
		dividiere(drei, NatürlicheZahl([2])) == Zahl(
			false,
			Bruch([1], [2]),
			[1]
	)
	);
	writeln("läuft");

	write("Testiere dividiere(Zahl 3000, Zahl 2000)... ");
	assert(
		dividiere(
			Zahl(false, Bruch(), [0xB8, 0x0B]),
			Zahl(false, Bruch(), [0xD0, 0x07])) ==
			Zahl(
				false,
				Bruch([0xE8, 0x03], [0xD0, 0x07]),
				[1]
			)
	);
	writeln("läuft");

	writeln("========================================");
	writeln("All Zahlenoperationen funktionieren!");
	writeln("========================================");
	writeln;
}
