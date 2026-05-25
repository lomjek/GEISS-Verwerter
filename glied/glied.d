module glied.glied;

import std.stdio : write;

import variablen.wert;

abstract class Glied
{
	abstract Wert verwerte();
	abstract void schreibe_baum();
}

class InvalidGlied : Glied
{
    override Wert verwerte(){
        return Wert(WertTyp.INVALID, null);
    }

    override void schreibe_baum()
    {
        write("INVALID");
    }
}
