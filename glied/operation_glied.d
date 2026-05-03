module glied.operation_glied;

import glied.glied;
import glied.wert_glied;

import token.operatoren;
import token.variable;
import token.variablen_typ;

import std.stdio : write, writeln;
import std.array : join, array;
import std.algorithm.searching : canFind;
import std.algorithm : map;
import std.conv : to;

class OperationGlied : Glied
{
	public OperatorenTyp operationenTyp;
	public Wert_Glied[] werte;

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

	override Variable verwerte()
	{
		VariablenTyp[] vt_liste = werte.map!(x => x.typ).array;
		bool all_numbers = true;
		foreach (VariablenTyp vtyp; vt_liste)
		{
			if (!ZAHLEN_TYPEN.canFind(vtyp))
			{
				all_numbers = false;
			}
		}

		if (all_numbers)
		{
			double resultat = 0.0;
			bool first_pass = true;
			foreach (Wert_Glied wert; werte)
			{
				double momentaner_wert = 0.0;
				Variable momentane_verwertung = wert.verwerte();

				if (momentane_verwertung.typ == VariablenTyp.NATÜRLICHE_ZAHL)
				{
					uint tmp = *cast(uint*) momentane_verwertung.wert;
					momentaner_wert = tmp.to!double;
				}
				else if (momentane_verwertung.typ == VariablenTyp.GANZE_ZAHL)
				{
					int tmp = *cast(int*) momentane_verwertung.wert;
					momentaner_wert = tmp.to!double;
				}
				else if (momentane_verwertung.typ == VariablenTyp.ZAHL)
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

			}
		}
		// Handle other cases
		return Variable(VariablenTyp.INVALID, null);
	}

	this(OperatorenTyp op_typ)
	{
		operationenTyp = op_typ;
	}
}
