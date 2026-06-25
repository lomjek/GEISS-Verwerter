module ut_zahl;

import zahl;

// @ {} [] # \ || != ~

unittest
{
	Bruch b_drittel = Bruch([1], [3]);
	Bruch b_viertel = Bruch([1], [4]);

	NatürlicheZahl drei = NatürlicheZahl([3]);

	assert(ist_grösser(b_drittel, b_viertel)); // ist_grösser Bruch
	assert(ist_grösser_gleich_1(b_viertel) == false); // auch für Brüche
	assert(ist_grösser_gleich_1(dividiere(b_drittel, b_viertel)) == true);

}
