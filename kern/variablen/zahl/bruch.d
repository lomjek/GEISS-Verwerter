module zahl.bruch;

import zahl.nzahl;
import zahl.gzahl;

// @ {} [] # \ || != ~

struct Bruch
{
	Nzahl zähler;
	Nzahl nenner;

	//MARK: THIS()
	pure nothrow
	this(const ubyte[] nzähler, const ubyte[] nnenner)
	{
		this.zähler = Nzahl(zähler);
		this.nenner = Nzahl(nenner);
	}

	pure nothrow
	this(const Nzahl nzähler, const Nzahl nnenner)
	{
		this.zähler = Nzahl(zähler);
		this.nenner = Nzahl(nenner);
	}

	pure nothrow
	this(const Bruch bruch)
	{
		zähler = Nzahl(bruch.zähler);
		nenner = Nzahl(bruch.nenner);
	}

	//MARK: opCmp
	pure nothrow
	int opCmp(const Bruch other) const
	{
		Nzahl zähler1 = this.zähler * other.nenner;
		Nzahl zähler2 = other.zähler * this.nenner;

		return Nzahl(zähler1).opCmp(Nzahl(zähler2));
	}

	pure nothrow
	bool opEquals(Bruch other) const
	{
		return this.opCmp(other) == 0;
	}

	//MARK: opBinary
	Bruch opBinary(string op, R)(const R other) const
	{
		static if (is(R == Bruch))
		{
			switch (op)
			{
			case "+":
				return addiere(other);

			case "-":
				return subtrahiere(other);

			case "*":
				return multipliziere(other);

			case "/":
				return dividiere(other);

			default:
				debug
				{
					import std.stdio : write, writeln;

					write("FEHLER: Der Operator kann nicht an Nzahl ausgeführt werden: ");
					writeln(op);
				}
				return Bruch();
			}
		}
		else
			return Bruch();
	}

	//MARK: ADDIERE
	private pure nothrow
	Bruch addiere(const Bruch other) const
	{
		if (other.zähler.opCmp(Nzahl.init) == 0)
			return Bruch(this);

		else if (this.zähler.opCmp(Nzahl.init) == 0)
			return Bruch(other);

		Nzahl neuer_nenner = this.nenner * other.nenner;

		Nzahl summand1 = this.zähler * other.nenner;
		Nzahl summand2 = other.zähler * this.nenner;

		return Bruch(summand1 + summand2, neuer_nenner);
	}

	//MARK: SUBTRAHIERE
	private pure nothrow
	Bruch subtrahiere(const Bruch other) const
	{
		debug
		{
			import std.stdio : write, writeln;

			if (other > this)
				write("FEHLER: Man kann nicht das grössere vom kleinern Subtrahieren");
		}

		Nzahl neuer_nenner = this.nenner * other.nenner;

		Nzahl summand1 = this.zähler * other.nenner;
		Nzahl summand2 = other.zähler * this.nenner;

		Nzahl neuer_zähler = summand1 - summand2;

		return Bruch(neuer_zähler, neuer_nenner);
	}

	//MARK: MULTIPLIZIERE
	private pure nothrow
	Bruch multipliziere(const Bruch other) const
	{
		return Bruch(this.zähler * other.zähler, this.nenner * other.zähler);
	}

	//MARK: DIVIDIERE
	private pure nothrow
	Bruch dividiere(const Bruch other) const
	{
		//TODO
		return Bruch(this.zähler * other.nenner, this.nenner * other.zähler);
	}
}
