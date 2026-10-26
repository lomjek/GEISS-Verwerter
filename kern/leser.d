module leser;

import ext.string;
import ext.prints;
import ext.klasse : instanceof, is_class;
import ext.algorithm : contains, remove, startsWith, endsWith, filter;
import ext.klasse : instanceof;

import glied.glied;
import glied.wert_glied;
import glied.variablen_glied;
import glied.operation_glied;

import schlüsselwörter;
import operatoren;
import zahl;
import text;
import wert;

import std.conv : to;
import std.stdio : write, writeln;
import std.array : split, array;
import std.traits : EnumMembers;

// @ {} [] # \ || != ~

// MARK: Wert - ist?
private bool ist_wert_wahrheit(dstring wort)
{
  return wort == "wahr"d || wort == "falsch"d;
}

//MARK: Wert - als!
private Wert als_wert_wahrheit(dstring wort)
{
  if (wort == "wahr"d)
  {
    return Wert(new bool(true));
  }
  else if (wort == "falsch"d)
  {
    return Wert(new bool(false));
  }

  return Wert(WertTyp.INVALID, null);
}

// MARK: lese_linie
Glied[] lese_linie(dstring linie)
{
  // Mache Platz vor und nach den Operatoren, damit sie aufgetrennt werden
  foreach (op; EnumMembers!OperatorenTyp)
  {
    dstring to_convert = [' ', operatoren_chars[op], ' '];
    linie = replaceAll(linie, operatoren_chars[op],
      to_convert);
  }

  Glied[] token_liste;

  dstring[] wort_liste = linie.split(" ");

  ulong wort_liste_length = wort_liste.length;
  dstring wort_präfix;

  for (ulong i = 0; i < wort_liste_length; i++)
  {
    dstring wort = wort_liste[i].strip;

    wort = wort_präfix ~ wort;
    wort_präfix = [];

    // Clean up
    if (wort.length == 0)
    {
      continue;
    }

    if (wort_liste.length > i + 2)
    {
      if (wort.ist_zahl && wort_liste[i + 1] == ".")
      {
        Zahl z;

        if ((wort_liste[i + 2]).ist_zahl)
        {
          z = als_zahl(wort ~ wort_liste[i + 1] ~ wort_liste[i + 2]);

          wort_liste = wort_liste.remove(i + 2);
          wort_liste = wort_liste.remove(i + 1);
          wort_liste_length -= 2;
        }
        else
        {
          z = als_zahl(wort);

          wort_liste = wort_liste.remove(i + 1);
          wort_liste_length--;
        }

        wort_liste[i] = " ";
        token_liste ~= new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(z)));
        continue;
      }
    }

    // WertTypen
    if (wort.wort_ist_wert_typ)
    {
      token_liste ~= wort_als_wert_typ(wort_liste, &i);
      continue;
    }

    //schlüsselwörter
    if (wort.wort_ist_sw)
    {
      token_liste ~= wort_als_sw(wort_liste, &i);
      continue;
    }

    // Werte
    if (wort.ist_zahl)
    {
      token_liste ~= new Wert_Glied(Wert(WertTyp.ZAHL, new Zahl(als_zahl(wort))));
      continue;
    }

    if (wort.beginnt_text)
    {
      token_liste ~= new Wert_Glied(Wert(new Text(als_wert_text(wort_liste, &i))));
      continue;
    }

    if (wort.ist_wert_wahrheit)
    {
      token_liste ~= new Wert_Glied(wort.als_wert_wahrheit);
      continue;
    }

    if (wort.wort_ist_op)
    {
      token_liste ~= wort_als_op(wort_liste, &i);
      continue;
    }

    // If none of the above treat as variable name
    token_liste ~= new Lese_Variable_Glied(wort);
  }

  debug
  {
    write("GL (1.0): ");
    set_pen_trait(TextTrait.fgGrey);
    writeln(token_liste);
    set_pen_trait();
  }

  ulong length = token_liste.length;

  //MARK: Aufräumen
  for (ulong i = 1; i < length; i++) // Der erste Durchgang beachtet Minuszahlen
  {
    if (token_liste[i].classinfo == Wert_Glied.classinfo &&
      token_liste[i - 1].classinfo == OperationGlied.classinfo)
    {
      Wert* var = &(cast(Wert_Glied) token_liste[i]).wert;
      OperatorenTyp op_typ = (cast(OperationGlied) token_liste[i - 1]).operationenTyp;

      // Falls nach dem Minus ein anderer Operator ist, lassen wir ihn liegen.
      if ((i > 1) && (token_liste[i - 2].instanceof!Wert_Glied ||
          token_liste[i - 2].instanceof!Lese_Variable_Glied))
      {
        continue;
      }

      if (op_typ == OperatorenTyp.MINUS)
      {
        if (var.typ == WertTyp.ZAHL)
        {
          Zahl* z = cast(Zahl*) var.wert;
          z.vor_komma.positiv = false;
          (cast(Wert_Glied) token_liste[i]).wert = Wert(WertTyp.ZAHL, new Zahl(*z));
          token_liste = token_liste.remove(i - 1);
          i--;
          length--;
          continue;
        }
      }
    }
  }

  //MARK: Hier werden Kommentare gefiltert.
  Glied[] glieder_liste = [];

  bool kommentar_an = false;
  bool kommentar_linie_an = false;

  for (size_t i = 0; i < token_liste.length; i++)
  {
    if (token_liste[i].instanceof!OperationGlied)
    {
      OperatorenTyp opt = (cast(OperationGlied) token_liste[i]).operationenTyp;

      if (opt == OperatorenTyp.ANFANG_KOMMENTAR &&
        !kommentar_an && !kommentar_linie_an)
      {
        kommentar_an = true;
        continue;
      }

      else if (opt == OperatorenTyp.ENDE_KOMMENTAR &&
        kommentar_an && !kommentar_linie_an)
      {
        kommentar_an = false;
        continue;
      }

      else if (opt == OperatorenTyp.ANFANG_LINIE_KOMMENTAR &&
        !kommentar_an && !kommentar_linie_an)
      {
        kommentar_linie_an = true;
        continue;
      }

      else if (opt == OperatorenTyp.NEUE_LINIE &&
        !kommentar_an && kommentar_linie_an)
      {
        kommentar_linie_an = false;
        continue;
      }

      if (separatoren.contains(opt))
        continue;
    }

    if (!kommentar_linie_an && !kommentar_an)
    {
      glieder_liste ~= token_liste[i];
    }
  }

  debug
  {
    write("GL (1.1): ");
    set_pen_trait(TextTrait.fgGrey);
    writeln(glieder_liste);
    set_pen_trait();
  }

  return glieder_liste;
}
