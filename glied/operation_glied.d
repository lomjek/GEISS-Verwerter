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
	public Glied[] werte;
	public bool populated = false;

	override void schreibe_baum()
	{
		write("[", operationenTyp, "]{");
		for (int i = 0; i < werte.length; i++)
		{
			werte[i].schreibe_baum();
			if (i + 1 < werte.length)
			{
				write(", ");
			}
		}
		write("}");
	}

	override Wert verwerte(uint bereich)
	{
		Wert resultat = Wert(WertTyp.INVALID, null);
		bool first_pass = true;
		foreach (Glied wert; werte)
		{
			Wert momentaner_wert = wert.verwerte(bereich);

			if (first_pass)
			{
				resultat = momentaner_wert;
				first_pass = false;
				continue;
			}

		ots:
			switch (operationenTyp)
			{
			case OperatorenTyp.PLUS:
				switch (resultat.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) resultat.wert;

					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) momentaner_wert
							.wert;

						NatürlicheZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new NatürlicheZahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = addiere(GanzeZahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = addiere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}

				case WertTyp.GANZE_ZAHL:
					GanzeZahl zwischenresultat = *cast(GanzeZahl*) resultat.wert;
					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						GanzeZahl alte_zahl = GanzeZahl(
							*cast(NatürlicheZahl*) momentaner_wert.wert);

						GanzeZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = addiere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);

					}

				case WertTyp.ZAHL:
					Zahl zwischenresultat = *cast(Zahl*) resultat.wert;

					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						Zahl alte_zahl = Zahl(*cast(NatürlicheZahl*) momentaner_wert.wert);

						Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						Zahl alte_zahl = Zahl(*cast(GanzeZahl*) momentaner_wert.wert);

						Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = addiere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}

				default:
					throw new Fehler(
						"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!dstring);
				}

			case OperatorenTyp.MINUS:
				switch (resultat.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) resultat.wert;
					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = subtrahiere(zwischenresultat, alte_zahl);

						resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = subtrahiere(GanzeZahl(zwischenresultat), alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = subtrahiere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}

				case WertTyp.GANZE_ZAHL:
					GanzeZahl zwischenresultat = *cast(GanzeZahl*) resultat.wert;
					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = subtrahiere(zwischenresultat, GanzeZahl(alte_zahl));

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = subtrahiere(GanzeZahl(zwischenresultat), alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = subtrahiere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				case WertTyp.ZAHL:
					Zahl zwischenresultat = *cast(Zahl*) resultat.wert;
					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) momentaner_wert.wert;

						Zahl neue_zahl = subtrahiere(zwischenresultat, Zahl(alte_zahl));

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						Zahl neue_zahl = subtrahiere(zwischenresultat, Zahl(alte_zahl));

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = subtrahiere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
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
					NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) resultat.wert;

					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						NatürlicheZahl alte_zahl = *cast(NatürlicheZahl*) momentaner_wert
							.wert;

						NatürlicheZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new NatürlicheZahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = multipliziere(GanzeZahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.GANZE_ZAHL, new GanzeZahl(neue_zahl));
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = multipliziere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}

				case WertTyp.GANZE_ZAHL:
					GanzeZahl zwischenresultat = *cast(GanzeZahl*) resultat.wert;
					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						GanzeZahl alte_zahl = GanzeZahl(
							*cast(NatürlicheZahl*) momentaner_wert.wert);

						GanzeZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						GanzeZahl alte_zahl = *cast(GanzeZahl*) momentaner_wert.wert;

						GanzeZahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new GanzeZahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = multipliziere(Zahl(zwischenresultat), alte_zahl);

						resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);

					}

				case WertTyp.ZAHL:
					Zahl zwischenresultat = *cast(Zahl*) resultat.wert;

					switch (momentaner_wert.typ)
					{
					case WertTyp.NATÜRLICHE_ZAHL:
						Zahl alte_zahl = Zahl(*cast(NatürlicheZahl*) momentaner_wert.wert);

						Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.GANZE_ZAHL:
						Zahl alte_zahl = Zahl(*cast(GanzeZahl*) momentaner_wert.wert);

						Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					case WertTyp.ZAHL:
						Zahl alte_zahl = *cast(Zahl*) momentaner_wert.wert;

						Zahl neue_zahl = multipliziere(zwischenresultat, alte_zahl);

						resultat.wert = new Zahl(neue_zahl);
						break ots;

					default:
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}

				default:
					throw new Fehler(
						"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!dstring);
				}

			case OperatorenTyp.GETEILT:
				goto default; //TODO: Implementieren

			case OperatorenTyp.GLEICH:
				if (resultat.typ == momentaner_wert.typ)
				{
					if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						NatürlicheZahl num1 = *cast(NatürlicheZahl*) resultat.wert;
						NatürlicheZahl num2 = *cast(NatürlicheZahl*) momentaner_wert.wert;
						bool gleich = is_equal(num1.werte, num2.werte);
						resultat = Wert(WertTyp.WAHRHEIT, new bool(gleich));
						break ots;
					}
					else if (resultat.typ == WertTyp.GANZE_ZAHL)
					{
						GanzeZahl num1 = *cast(GanzeZahl*) resultat.wert;
						GanzeZahl num2 = *cast(GanzeZahl*) momentaner_wert.wert;
						bool gleich = num1.negativ == num2.negativ;
						if (gleich)
						{
							gleich = is_equal(num1.werte, num2.werte);
						}
						resultat = Wert(WertTyp.WAHRHEIT, new bool(gleich));
						break ots;
					}

				}
				else
				{
					goto default; //TODO: Implementieren, falls 3 gzahl mit 3 nzahl verglichen wird...
				}
				break ots; // TODO: Warum braucht es das hier?

			case OperatorenTyp.GRÖSSER_ALS:
				if (resultat.typ == momentaner_wert.typ)
				{
					if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						NatürlicheZahl num1 = *cast(NatürlicheZahl*) resultat.wert;
						NatürlicheZahl num2 = *cast(NatürlicheZahl*) momentaner_wert.wert;
						resultat = Wert(WertTyp.WAHRHEIT, new bool(ist_grösser(num1.werte, num2
								.werte)));
						break ots;
					}
				}
				break ots;

			case OperatorenTyp.KLEINER_ALS:
				if (resultat.typ == momentaner_wert.typ)
				{
					if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						NatürlicheZahl num1 = *cast(NatürlicheZahl*) resultat.wert;
						NatürlicheZahl num2 = *cast(NatürlicheZahl*) momentaner_wert.wert;
						resultat = Wert(WertTyp.WAHRHEIT, new bool(ist_grösser(num2.werte, num1
								.werte)));
						break ots;
					}
				}
				break ots;

			default:
				throw new Fehler(
					"Dieser Operator wurde nicht implementiert..." ~ operationenTyp.to!dstring);
			}
		}
		return resultat;
	}

	override public bool ist_vollständig()
	{
		return populated;
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
