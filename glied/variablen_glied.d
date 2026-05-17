module glied.variablen_glied;

import token.variable;

import variablen.wert_typ;

import glied.glied;

class Setze_Variable_Glied : Glied
{
	override public Variable verwerte()
	{
		return Variable(WertTyp.INVALID, null);

		// Ich muss mir ein System für Variablen überlegen.
	}
}

class Lese_Variable_Glied : Glied
{
}
