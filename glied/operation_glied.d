module glied.operation_glied;

import glied.glied;
import glied.wert_glied;

import operatoren;

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

	override Wert verwerte()
	{
		WertTyp[] vt_liste = werte.map!(werte => werte.verwerte.typ).array;
		bool all_numbers = true;
		foreach (WertTyp vtyp; vt_liste)
		{
			if (!ZAHLEN_TYPEN.canFind(vtyp))
			{
				write(vtyp);
				all_numbers = false;
			}
		}

		if (all_numbers)
		{
			double resultat = 0.0;
			bool first_pass = true;
			foreach (Glied wert; werte)
			{
				double momentaner_wert = 0.0;
				Wert momentane_verwertung = wert.verwerte();

				if (momentane_verwertung.typ == WertTyp.NATÜRLICHE_ZAHL)
				{
					uint tmp = *cast(uint*) momentane_verwertung.wert;
					momentaner_wert = tmp.to!double;
				}
				else if (momentane_verwertung.typ == WertTyp.GANZE_ZAHL)
				{
					int tmp = *cast(int*) momentane_verwertung.wert;
					momentaner_wert = tmp.to!double;
				}
				else if (momentane_verwertung.typ == WertTyp.ZAHL)
				{
					momentaner_wert = *cast(double*) momentane_verwertung.wert;
				}
				else
				{
					debug writeln(
						"Irgendwelche schlimme Fehler sind passiert. OperationGlied bei verwertung mit allnumbers.");
				}

				if (first_pass)
				{
					resultat = momentaner_wert;
					first_pass = false;
					continue;
				}

				if (operationenTyp == OperatorenTyp.PLUS)
				{
					resultat += momentaner_wert;
				}
				else if (operationenTyp == OperatorenTyp.MINUS)
				{
					resultat -= momentaner_wert;
				}
				else if (operationenTyp == OperatorenTyp.MAL)
				{
					resultat *= momentaner_wert;
				}
				else if (operationenTyp == OperatorenTyp.HOCH)
				{
					resultat = pow(resultat, momentaner_wert);
				}
			}

			double* heap_resultat = new double;
			*heap_resultat = resultat;
			return Wert(WertTyp.ZAHL, heap_resultat);
		}
		// Handle other cases
		return Wert(WertTyp.INVALID, null);
	}

	this(OperatorenTyp op_typ)
	{
		operationenTyp = op_typ;
	}
}
