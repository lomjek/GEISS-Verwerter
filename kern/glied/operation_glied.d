module glied.operation_glied;

import glied.glied;
import glied.wert_glied;

import ext.prints;

import operatoren;
import fehler;
import zahl;
import wert;

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
				Nzahl zwischenresultat = *cast(Nzahl*) wert2.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Nzahl alte_zahl = *cast(Nzahl*) wert2
						.wert;

					Nzahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = Gzahl(zwischenresultat) + alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) + alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				Gzahl zwischenresultat = *cast(Gzahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Gzahl alte_zahl = Gzahl(
						*cast(Nzahl*) wert2.wert);

					Gzahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) + alte_zahl;

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
					Zahl alte_zahl = Zahl(*cast(Nzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(Gzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat + alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!string);
			}

		case OperatorenTyp.MINUS:
			switch (resultat.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				Nzahl zwischenresultat = *cast(Nzahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Nzahl alte_zahl = *cast(Nzahl*) wert2.wert;

					Gzahl neue_zahl = zwischenresultat - alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = Gzahl(zwischenresultat) - alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) - alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				Gzahl zwischenresultat = *cast(Gzahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Nzahl alte_zahl = *cast(Nzahl*) wert2.wert;

					Gzahl neue_zahl = zwischenresultat - Gzahl(alte_zahl);

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = Gzahl(zwischenresultat) - alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) - alte_zahl;

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
					Nzahl alte_zahl = *cast(Nzahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat - alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat - alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat - alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}
			default:
				throw new Fehler(
					"Es wurde für folgende Typ noch nicht Minus implementiert..." ~ resultat
						.typ.to!string);
			}
		case OperatorenTyp.MAL:
			switch (wert1.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				Nzahl zwischenresultat = *cast(Nzahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Nzahl alte_zahl = *cast(Nzahl*) wert2
						.wert;

					Nzahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.NATÜRLICHE_ZAHL, new Nzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = Gzahl(zwischenresultat) * alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) * alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				Gzahl zwischenresultat = *cast(Gzahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Gzahl alte_zahl = Gzahl(
						*cast(Nzahl*) wert2.wert);

					Gzahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Gzahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.GANZE_ZAHL, new Gzahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = Zahl(zwischenresultat) * alte_zahl;

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
					Zahl alte_zahl = Zahl(*cast(Nzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(Gzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat * alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"MAL geht für volgendes Typ nicht: " ~
						wert1.als_string(Str_conv_typ.INTERNAL) ~ " " ~ operationenTyp.to!string ~ " "
						~ wert2.als_string(Str_conv_typ.INTERNAL));
			}

		case OperatorenTyp.GETEILT:
			switch (wert1.typ)
			{
			case WertTyp.NATÜRLICHE_ZAHL:
				Nzahl zwischenresultat = *cast(Nzahl*) wert1.wert;

				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Nzahl alte_zahl = *cast(Nzahl*) wert2
						.wert;

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Zahl neue_zahl = (Gzahl(zwischenresultat) / alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = (Zahl(zwischenresultat) / alte_zahl);

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			case WertTyp.GANZE_ZAHL:
				Gzahl zwischenresultat = *cast(Gzahl*) wert1.wert;
				switch (wert2.typ)
				{
				case WertTyp.NATÜRLICHE_ZAHL:
					Gzahl alte_zahl = Gzahl(
						*cast(Nzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Gzahl alte_zahl = *cast(Gzahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));

					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = (Zahl(zwischenresultat) / alte_zahl);

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
					Zahl alte_zahl = Zahl(*cast(Nzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.GANZE_ZAHL:
					Zahl alte_zahl = Zahl(*cast(Gzahl*) wert2.wert);

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				case WertTyp.ZAHL:
					Zahl alte_zahl = *cast(Zahl*) wert2.wert;

					Zahl neue_zahl = zwischenresultat / alte_zahl;

					resultat = Wert(WertTyp.ZAHL, new Zahl(neue_zahl));
					break ots;

				default:
					throw new Operation_TypenFehler(this.operationenTyp,
						resultat.typ, wert2.typ);
				}

			default:
				throw new Fehler(
					"Man kann nicht anderes Plusrechnen" ~ operationenTyp.to!string);
			}

		case OperatorenTyp.GLEICH:
		  resultat = Wert(new bool(wert1 == wert2));
      break ots; // TODO: Warum braucht es das hier?

		case OperatorenTyp.GRÖSSER_ALS:
			resultat = Wert(new bool(wert1 > wert2));
      break ots;

		case OperatorenTyp.KLEINER_ALS:
      resultat = Wert(new bool(wert1 < wert2));
			break ots;

    case OperatorenTyp.GRÖSSER_GLEICH:
      resultat = Wert(new bool(wert1 >= wert2));
      break ots;

    case OperatorenTyp.KLEINER_GLEICH:
      resultat = Wert(new bool(wert1 <= wert2));
      break ots;

		default:
			throw new Fehler(
				"Dieser Operator wurde nicht implementiert..." ~ operationenTyp.to!string);
		}
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

  this(OperatorenTyp op_typ, Glied wert1, Glied wert2){
    operationenTyp = op_typ;
    werte[0] = wert1;
    werte[1] = wert2;
  }

	override string toString() const
	{
		return "G(OPERATOR | " ~ this.operationenTyp.to!string ~ ")";
	}
}
