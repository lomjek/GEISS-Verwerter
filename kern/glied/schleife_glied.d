module glied.schleife_glied;

import glied.block_glied;
import glied.glied : Glied;
import variablen.wert;
import zahl;

import std.stdio : write, writeln;
import std.conv : to;

// @ {} [] # \ || != ~

//MARK: SOLANGE
class Solange_BlockGlied : BlockGlied
{
	Glied bedingung;

	override public void schreibe_baum()
	{
		write("[SOLANGE ");
		bedingung.schreibe_baum();
		write("]{");
		schreibe_glied_liste(this.aktionen);
		write("}");
	}

	private bool erfüllt(uint bereich)
	{
		Wert wert_bedingung = bedingung.verwerte(bereich);
		return wert_bedingung.ist_wahr;
	}

	override public Wert verwerte(uint bereich)
	{
		while (erfüllt(bereich))
		{
			verwerte_glieder_liste(bereich, aktionen);
		}
		return Wert(WertTyp.INVALID, null);
	}

	override public bool ist_vollständig()
	{
		return (bedingung !is null) && (aktionen.length !is 0);
	}

	override string toString() const
	{
		return "G(SOLANGE | " ~ aktionen.length.to!string ~ ")";
	}
}

//MARK: WIEDERHOLE
class Wiederhole_BlockGlied : BlockGlied
{
  Glied wiederholungen;

  private Nzahl gebrauchte_wiederholungen;
  private Nzahl gemachte_wiederholungen = Nzahl();

  override public void schreibe_baum()
	{
		write("[WIEDERHOLE ");
		wiederholungen.schreibe_baum();
		write("]{");
		schreibe_glied_liste(this.aktionen);
		write("}");
	}

  override public Wert verwerte(uint bereich)
	{
    Wert wdh = wiederholungen.verwerte(bereich);

    if (wdh.typ == WertTyp.NATÜRLICHE_ZAHL){
      gebrauchte_wiederholungen = Nzahl(*cast(Nzahl*) wdh.wert);
    }
    else if (wdh.typ == WertTyp.GANZE_ZAHL){
      gebrauchte_wiederholungen = Nzahl((*cast(Gzahl*) wdh.wert).grösse);
    }
    else if (wdh.typ == WertTyp.ZAHL){
      gebrauchte_wiederholungen = Nzahl((*cast(Zahl*) wdh.wert).grösse);
    }

		while (gebrauchte_wiederholungen > gemachte_wiederholungen)
		{
      gemachte_wiederholungen = gemachte_wiederholungen + Nzahl([1]);

			verwerte_glieder_liste(bereich, aktionen);
		}
		return Wert(WertTyp.INVALID, null);
	}

  override public bool ist_vollständig()
	{
		return (wiederholungen !is null) && (aktionen.length !is 0);
	}
	
  override string toString() const
	{
		return "G(WIEDERHOLE | " ~ aktionen.length.to!string ~ ")";
	}
}
