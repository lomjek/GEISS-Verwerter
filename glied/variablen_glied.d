module glied.variablen_glied;

import variablen.wert;

import glied.glied;

class Setze_Variable_Glied : Glied
{
	override public Wert verwerte(uint bereich)
	{
		return Wert(WertTyp.INVALID, null);

		// Ich muss mir ein System für Variablen überlegen.
	}
}

class Lese_Variable_Glied : Glied
{
}
