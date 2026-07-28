module glied.operation_glied;

import glied.glied;
import glied.wert_glied;

import ext.prints;

import operatoren;
import fehler;
import zahl;
import variablen.wert;

import std.stdio : write, writeln;
import std.array : join, array;
import std.algorithm.searching : canFind;
import std.algorithm : map;
import std.conv : to;

// @ {} [] # \ || != ~

class OperationGlied : Glied
{
	public OperatorenTyp operationenTyp;
	public Glied[2] werte;
	public bool populated = false;

	override void schreibe_baum()
	{
		write("{");
		werte[0].schreibe_baum();
		write(" ");
		write(operationenTyp);
		write(" ");
		werte[1].schreibe_baum();
		write("}");
	}

	override Wert verwerte(uint bereich)
	{
		Wert wert1 = werte[0].verwerte(bereich);
		Wert wert2 = werte[1].verwerte(bereich);
		Wert resultat = Wert();

	ots:
		switch (operationenTyp)
		{
		case OperatorenTyp.PLUS:
			switch (wert1.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) wert2.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2
						.wert;

					NatürlicheZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.NATÜRLICHE_ZAHL, new NatürlicheZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = addiere(GanzeZahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = addiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				GanzeZahl zwischenresultat = *cast(GanzeZahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					GanzeZahl alte_zahl = GanzeZahl(
						*cast(NatürlicheZahl*) wert2.wert);

					GanzeZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = addiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);

				}

			case WertTyp.ZAHL:
				Zahl zwischenresultat = *cast(Zahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(NatürlicheZahl*) wert2.wert);

					Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(GanzeZahl*) wert2.wert);

					Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!dstring);
			}

		case OperatorenTyp.MINUS:
			switch (resultat.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2.wert;

					GanzeZahl neue_zahl = subtrahiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = subtrahiere(GanzeZahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = subtrahiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				GanzeZahl zwischenresultat = *cast(GanzeZahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2.wert;

					GanzeZahl neue_zahl = subtrahiere(zwischenresultat, GanzeZahl(alte_zahl));

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = subtrahiere(GanzeZahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = subtrahiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}
			case WertTyp.ZAHL:
				Zahl zwischenresultat = *cast(Zahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2.wert;

					Zahl neue_zahl = subtrahiere(zwischenresultat, Zahl(alte_zahl));

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					Zahl neue_zahl = subtrahiere(zwischenresultat, Zahl(alte_zahl));

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = subtrahiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}
			default:
				throw new Fehler(
					"Es wurde für folgende Typ noch nicht Minus implementiert..." ~ resultat
						.typ.to!dstring);
			}
		case OperatorenTyp.MAL:
			switch (resultat.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2
						.wert;

					NatürlicheZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.NATÜRLICHE_ZAHL, new NatürlicheZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = multipliziere(GanzeZahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = multipliziere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				GanzeZahl zwischenresultat = *cast(GanzeZahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					GanzeZahl alte_zahl = GanzeZahl(
						*cast(NatürlicheZahl*) wert2.wert);

					GanzeZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					GanzeZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = multipliziere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);

				}

			case WertTyp.ZAHL:
				Zahl zwischenresultat = *cast(Zahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(NatürlicheZahl*) wert2.wert);

					Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(GanzeZahl*) wert2.wert);

					Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!dstring);
			}

		case OperatorenTyp.GETEILT: //TODO
			switch (resultat.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) wert2
						.wert;

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					Zahl neue_zahl = dividiere(GanzeZahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = dividiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				GanzeZahl zwischenresultat = *cast(GanzeZahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					GanzeZahl alte_zahl = GanzeZahl(
						*cast(NatürlicheZahl*) wert2.wert);

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					GanzeZahl alte_zahl = *cast(GanzeZahl*) wert2.wert;

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));

					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = dividiere(Zahl(zwischenresultat), alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);

				}

			case WertTyp.ZAHL:
				Zahl zwischenresultat = *cast(Zahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(NatürlicheZahl*) wert2.wert);

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(GanzeZahl*) wert2.wert);

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = dividiere(zwischenresultat, alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!dstring);
			}

		case OperatorenTyp.GLEICH:
			if (wert1.typ == wert2.typ)
			{
				if (wert1.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					NatürlicheZahl num1 = *cast(NatürlicheZahl*) wert1.wert;
					NatürlicheZahl num2 = *cast(NatürlicheZahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 == num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.GANZE_ZAHL)
				{
					GanzeZahl num1 = *cast(GanzeZahl*) wert1.wert;
					GanzeZahl num2 = *cast(GanzeZahl*) wert2.wert;

					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 == num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.ZAHL)
				{
					Zahl num1 = *cast(Zahl*) wert1.wert;
					Zahl num2 = *cast(Zahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 == num2));
					break ots;
				}

			}
			else
			{
				goto default; //TODO: Implementieren, falls 3 gzahl mit 3 nzahl verglichen wird...
			}
			break ots; // TODO: Warum braucht es das hier?

		case OperatorenTyp.GRÖSSER_ALS:
			if (wert1.typ == wert2.typ)
			{
				if (wert1.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					NatürlicheZahl num1 = *cast(NatürlicheZahl*) wert1.wert;
					NatürlicheZahl num2 = *cast(NatürlicheZahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 > num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.GANZE_ZAHL)
				{
					GanzeZahl num1 = *cast(GanzeZahl*) wert1.wert;
					GanzeZahl num2 = *cast(GanzeZahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 > num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.ZAHL)
				{
					Zahl num1 = *cast(Zahl*) wert1.wert;
					Zahl num2 = *cast(Zahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 > num2));
					break ots;
				}
			}
			break ots;

		case OperatorenTyp.KLEINER_ALS:
			if (wert1.typ == wert2.typ)
			{
				if (wert1.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					NatürlicheZahl num1 = *cast(NatürlicheZahl*) wert1.wert;
					NatürlicheZahl num2 = *cast(NatürlicheZahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 < num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.GANZE_ZAHL)
				{
					GanzeZahl num1 = *cast(GanzeZahl*) wert1.wert;
					GanzeZahl num2 = *cast(GanzeZahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 < num2));
					break ots;
				}
				else if (wert1.typ == WertTyp.ZAHL)
				{
					Zahl num1 = *cast(Zahl*) wert1.wert;
					Zahl num2 = *cast(Zahl*) wert2.wert;
					resultat = Wert(WertTyp.WAHRHEIT, new bool(num1 < num2));
					break ots;
				}
			}
			break ots;

		default:
			throw new Fehler(
				"Dieser Operator wurde nicht implementiert..." ~ operationenTyp.to!dstring);
		}
		writeln(resultat);
		return resultat;
	}

	override public bool ist_vollständig()
	{
		return (werte[0]!is null) && (werte[1]!is null);
	}

	this(OperatorenTyp op_typ)
	{
		operationenTyp = op_typ;
	}

	override string toString() const
	{
		return "G(OPERATOR | " ~ this.operationenTyp.to!string ~ ")";
	}
}
