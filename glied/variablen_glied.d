module glied.variablen_glied;

import token.variable;
import token.variablen_typ;

import glied.glied;

class Setze_Variable_Glied : Glied
{
	override public Variable verwerte()
	{
		return Variable(VariablenTyp.INVALID, null);

		// Ich muss mir ein System für Variablen überlegen.
	}
}

class Lese_Variable_Glied : Glied
{
}
