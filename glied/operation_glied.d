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
import std.math.exponential : pow;

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

			//MARK: PLUS
			if (operationenTyp == OperatorenTyp.PLUS)
			{
				if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) resultat.wert;

					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						NatürlicheZahl* neue_zahl = new NatürlicheZahl;

						*neue_zahl = addiere(zwischenresultat,
							*cast(NatürlicheZahl*) momentaner_wert.wert);
						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;
						*neue_zahl = addiere(GanzeZahl(zwischenresultat),
							*cast(GanzeZahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.GANZE_ZAHL, neue_zahl);
					}
					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;

						*neue_zahl = addiere(Zahl(zwischenresultat),
							*cast(Zahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.ZAHL, neue_zahl);
					}
					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}

				else if (resultat.typ == WertTyp.GANZE_ZAHL)
				{
					GanzeZahl zwischenresultat = *cast(GanzeZahl*) resultat.wert;
					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;
						*neue_zahl = addiere(zwischenresultat,
							GanzeZahl(*cast(NatürlicheZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;
						*neue_zahl = addiere(zwischenresultat,
							*cast(GanzeZahl*) momentaner_wert.wert);

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = addiere(Zahl(zwischenresultat),
							*cast(Zahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.ZAHL, neue_zahl);
					}
					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}

				else if (resultat.typ == WertTyp.ZAHL)
				{
					Zahl zwischenresultat = *cast(Zahl*) resultat.wert;

					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						Zahl* neue_zahl = new Zahl;

						*neue_zahl = addiere(zwischenresultat,
							Zahl(*cast(NatürlicheZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = addiere(zwischenresultat,
							Zahl(*cast(GanzeZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = addiere(zwischenresultat,
							*cast(Zahl*) momentaner_wert.wert);

						resultat.wert = neue_zahl;
					}
					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}
				// Noch für andere Typen else ifs
			}

			//MARK: MINUS
			else if (operationenTyp == OperatorenTyp.MINUS)
			{
				if (resultat.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					NatürlicheZahl zwischenresultat = *cast(NatürlicheZahl*) resultat.wert;

					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;

						*neue_zahl = subtrahiere(zwischenresultat,
							*cast(NatürlicheZahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.GANZE_ZAHL, neue_zahl);
					}

					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;

						*neue_zahl = subtrahiere(GanzeZahl(zwischenresultat),
							*cast(GanzeZahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.GANZE_ZAHL, neue_zahl);
					}

					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;

						*neue_zahl = subtrahiere(Zahl(zwischenresultat),
							*cast(Zahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.ZAHL, neue_zahl);
					}

					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}

				else if (resultat.typ == WertTyp.GANZE_ZAHL)
				{
					GanzeZahl zwischenresultat = *cast(GanzeZahl*) resultat.wert;
					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;
						*neue_zahl = subtrahiere(zwischenresultat,
							GanzeZahl(*cast(NatürlicheZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						GanzeZahl* neue_zahl = new GanzeZahl;
						*neue_zahl = subtrahiere(zwischenresultat,
							*cast(GanzeZahl*) momentaner_wert.wert);

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = subtrahiere(Zahl(zwischenresultat),
							*cast(Zahl*) momentaner_wert.wert);

						resultat = Wert(WertTyp.ZAHL, neue_zahl);
					}
					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}

				else if (resultat.typ == WertTyp.ZAHL)
				{
					Zahl zwischenresultat = *cast(Zahl*) resultat.wert;
					if (momentaner_wert.typ == WertTyp.NATÜRLICHE_ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = subtrahiere(zwischenresultat,
							Zahl(*cast(NatürlicheZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.GANZE_ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = subtrahiere(zwischenresultat,
							Zahl(*cast(GanzeZahl*) momentaner_wert.wert));

						resultat.wert = neue_zahl;
					}
					else if (momentaner_wert.typ == WertTyp.ZAHL)
					{
						Zahl* neue_zahl = new Zahl;
						*neue_zahl = subtrahiere(zwischenresultat,
							*cast(Zahl*) momentaner_wert.wert);

						resultat.wert = neue_zahl;
					}
					else
					{
						throw new Operation_TypenFehler(this.operationenTyp,
							resultat.typ, momentaner_wert.typ);
					}
				}
			}
			/*
			else if (operationenTyp == OperatorenTyp.MAL)
			{
				resultat *= momentaner_wert;
			}
			else if (operationenTyp == OperatorenTyp.HOCH)
			{
				resultat = pow(resultat, momentaner_wert);
			}
			*/
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
}
