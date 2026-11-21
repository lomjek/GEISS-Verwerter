#set page(
  paper: "a4",
  header: "GEISS (Version Alpha.1) - Dokumentation", 
  footer: context {
    align(center, counter(page).display(
      "1 / 1",
      both: true,
    ))
  }
)

#set par(
  justify: true,
)

#set text(
  font: "New Computer Modern",
  lang: "de",
  region: "ch",
  size: 11pt,
)

// Code blocks bg
#show raw: it => {
  if it.block {
    block(
      fill: rgb("f1f3f5"),
      inset: 8pt,
      radius: 4pt,
      width: 100%,
      text(fill: rgb("2b2b2b"), font: "DejaVu Sans Mono", size: 0.9em, it)
    )
  } else {
    box(
      fill: rgb("f1f3f5"),
      inset: (x: 4pt, y: 0pt),
      outset: (y: 3pt),
      radius: 3pt,
      text(fill: rgb("2b2b2b"), font: "DejaVu Sans Mono", size: 0.9em, it)
    )
  }
}

//geiss
#let geiss(code) = box(
  fill: rgb("f1f3f5"),
  inset: (x: 4pt, y: 0pt),
  outset: (y: 3pt),
  radius: 3pt,
  text(font: "DejaVu Sans Mono", size: 0.8em)[
    #show regex("\b(variable|zahl|nzahl|natürliche|gzahl|ganze|text|liste)\b"): it => text(fill: rgb("#01007b"), it)

    #show regex("(<-|->|\b(falls|sonst|solange|nicht)\b)"): it => text(fill: rgb("#4f003d"), it, weight: "bold")

    #show regex("\"[^\"]*\"|\b[a-zA-Z_]\w*\b"): it => {
      let s = it.text
      if s.starts-with("\"") {
        text(fill: rgb("#3c7800"), it)
      } else {
        text(fill: rgb("#007d84"), it)
      }
    }

    #code
  ]
)

#let geiss_g(code) = block(
  fill: rgb("f1f3f5"),
  inset: (x: 4pt, y: 0pt),
  outset: (y: 3pt),
  radius: 3pt,
  width: 100%,
  text(font: "DejaVu Sans Mono", size: 1.2em)[
    #show regex("\b(funktion|variable|zahl|nzahl|natürliche|gzahl|ganze|text|liste)\b"): it => text(fill: rgb("#01007b"), it)

    #show regex("(<-|->|\b(falls|sonst|solange|nicht)\b)"): it => text(fill: rgb("#4f003d"), it, weight: "bold")

    #show regex("\"[^\"]*\"|\b[a-zA-Z_]\w*\b"): it => {
      let s = it.text
      if s.starts-with("\"") {
        text(fill: rgb("#3c7800"), it)
      } else {
        text(fill: rgb("#007d84"), it)
      }
    }

    #code
  ]
)

// Titel
#align(center)[
  #text(size: 2em, weight: "extrabold")[Dokumentation für]\
  #text(size: 2em, weight: "bold")[GEISS,] \
  #text(size: 1.5em)[eine imperative, starke Sprache] \
]

// Einleitung
GEISS ist eine Programmiersprache, welche ich für meine Maturaarbeit implementiert habe. Es ist eine interpretierte Sprache.

Diese Dokumentation ist die eigentliche, offizielle Dokumentation, welche ich führe. Sie sollte immer für den Release aktuell sein und mit dem Code übereinstimmen. Falls das nicht der Fall ist, dann schreiben Sie mir bitte.

// Table of Contents
#outline(indent: auto)

= Wie kann ich GEISS benützten?

GEISS ist eine interpretierte Sprache. Um GEISS also ausführen zu können, braucht man den Interpreter. Der Interpreter ist erhältlich bei #link("https://github.com/lomjek/GEISS-Verwerter")[GitHub]. Man kann ihn aus dem Quellencode selber bauen (Anweisungen dazu sind auf GitHub).

Wenn man den kompilierten Interpreter hat, kann man die entweder einfach laufen lassen. Das öffnet ein REPL, wo man Sachen austesten kann. Wenn man grössere Programme schreiben und auch speichern will, soll man eine Datei erstellen (präferiert wäre mit der Endung: "\*.geiss").

== Hallo Welt!

```geiss
schreibe("Hallo Welt!") 
```

Das ist der einfachste Weg, um "Hallo Welt" in die Ausgabe zu schreiben.
Wenn man "Hallo Welt" zuerst in einer Variablen speicher möchte, bevor man es in 
die Ausgabe schreibt, geht man wie folgt vor:

```geiss
text gruss <- "Hallo Welt!"

schreibe(gruss) 
```

= Verlauf des Interpreters

Ein Interpreter liest den Quellencode und führt ihn sofort aus. 
Um das zu erreichen, ist der Interpreter in mehrere Teile aufgetrennt.
Die Unterkapitel erklären in der richtigen Reihenfolge, wie man vom Quellencode bis
zum Ergebnis der Programms gelangt.  

== Lesen der Dateien
<lesen-der-dateien>

Da GEISS in D geschrieben wurde, weiss ich nicht alle Details des Lesen
der Dateien, allerdings kann ich aber gut erklären, was passiert, wie
eine Datei von meinem Interpreter verarbeitet wird.

#strong[1.] Wenn dein Programm gelesen wird, weden zuerst alle
Operatoren gesucht und es wird um sie ein Leerschlag eingefügt. \"2+3\"
\=\> \"2 + 3\". Eine Liste von Operatoren findest du
#link(<liste_operatoren>)[hier.]

#strong[2.] Der lange Text wird in eine grosse Liste von Wörtern
aufgeteilt.

#strong[3.] Jedes der Wörter in der Liste wird zu einem Glied
umfunktioniert. Ab diesem Punkt hat man mit dem Text keine Berührung
mehr. Von da an wird nur die lange Liste an Gliedern beachtet.

== Parsen

== Ausführen

= Datentypen
<Datentypen>

Es hat in GEISS wenige Datentypen, aber das ist absichtlich so. Es hat noch keine Structs, aber es hat noch keine Structs, was heisst, dass ich sie noch implementieren muss. Die Sprache ist dynamisch, sie hat aber überprüfungen während der Laufzeit, welche sicherstellen können, dass die Typen richtig sind. Es ist stark typisiert, was heisst, dass man nicht einfach so Variablen umcasten kann.

== Zahlen

== Text

Man kann Text mit "text" definieren. Ein Text kann Text enthalten. Es gibt praktisch kein Limit für die Länge, welcher nicht durch das Hardware oder das Betriebssystem bedingt sind. Man kann Text mit einfachen oder doppelten Quotes benutzten " '. Man kann sie auch mit dem Backslash vorher definieren. 

== Listen
== Wahrheiten

= Methoden
Es gibt einige Funktionen, welche schon vom Beginn des Programmes benutztbar sind. In meiner Sprache werden sie "Methoden" genannt. Es folgt eine Liste, welche die Funktionsweisen aller Methoden beschreibt.

#geiss_g[```geiss
funktion schreibe(variable eingabe)
```]

Diese Funktion schreibt die Variable, welche eingegeben wurde auf eine schön formatierte Art in die Ausgabe.

#geiss_g[```geiss
funktion als_text(zahl eingabe) -> text ausgabe
```]

Wandelt eine Zahl (es kann auch eine natürliche oder ganze Zahl sein) in einen Text um. Für die Umwandlung wird das Dezimalsystem benutzt.

#geiss_g[```geiss
funktion als_zahl(text eingabe) -> zahl ausgabe
```]

Liest einen Text und wandelt ihn in eine Zahl um. Falls der Text keine gültige Zahl enthält, stürzt das Programm ab.

#geiss_g[```geiss
funktion eingabe(text aufforderung) -> text ausgabe
```]

Schreibt die Aufforderung in die Ausgabe und wartet dann, bis der Nutzer seinen Text eingegeben hat und anschliessend ENTER gedrückt hat. Man kann noch nicht mit Pfeilen den Zeiger verschieben.

#geiss_g[```geiss
funktion zufällige_zahl(ganze zahl unteres_limit, ganze zahl oberes_limit) -> ganze zahl rzahl
```]

Erzeugt eine zufällige ganze Zahl im Bereich zwischen dem unteren und dem oberen Limit.

#geiss_g[```geiss
funktion indizes(liste liste) -> liste indizes
```]

Gibt eine Liste mit den Indizes der übergebenen Liste zurück. (Es ist nütztlich für pro/von-Schleifen)

= Zahlen und Listen

Vielleicht ist das nicht so spannend für nicht technische Leute, aber wenn jemand
mit GEISS programmiert und sich nicht sicher ist, ob der Fehler an ihm liegt, oder
an meiner Implementation von GEISS, dann können sich folgende Listen möglicherweise
als sehr nützlich auszeichnen.

== Liste der Operatoren
<liste_operatoren>

Unten finden Sie eine Tabelle mit allen Operatoren mit ihrem internen
Namen, ihrem Charakter und ihrem Nutzen in der Reihenfolge ihrer Definition im Quelltext.
#figure(
  align(center)[#table(
    columns: (auto,) * 2 + (1fr,),
    inset: 6pt,
    [PLUS], [`+`], [Addition von Werten], 
    [MINUS], [`-`], [Subtraktion von Werten],
    [MAL], [`*`], [Multiplikation von Werten],
    [GETEILT], [`/`], [Division von Werten], 
    [HOCH], [`^`], [Potenzierung von Werten], 
    [GLEICH], [`=`], [Vergleich auf Gleichheit], 
    [RÜCK_PFEIL], [`←` _oder_ `<-`], [Zuweisung / Setzen von Variablen], 
    [VOR_PFEIL], [`→` _oder_ `->`], [Deklaration von Rückgabewerten bei Funktionen], 
    [KLAMMER_AUF], [`(`], [Öffnende runde Klammer (Gruppierung, Funktionsaufrufe)], 
    [KLAMMER_ZU], [`)`], [Schliessende runde Klammer], 
    [ECKIGE_KLAMMER_AUF], [`[`], [Öffnende eckige Klammer (Listen, Indexzugriff, Typisierung)], 
    [ECKIGE_KLAMMER_ZU], [`]`], [Schliessende eckige Klammer], 
    [KLEINER_ALS], [`<`], [Vergleich: kleiner als], 
    [GRÖSSER_ALS], [`>`], [Vergleich: grösser als], 
    [GRÖSSER_GLEICH], [`≥` _oder_ `>=`], [Vergleich: grösser oder gleich], 
    [KLEINER_GLEICH], [`≤` _oder_ `<=`], [Vergleich: kleiner oder gleich], 
    [GESCHWUNGENE_KLAMMER_AUF], [`{`], [Öffnende geschweifte Klammer (Codeblöcke)], 
    [GESCHWUNGENE_KLAMMER_ZU], [`}`], [Schliessende geschweifte Klammer], 
    [PUNKT], [`.`], [Dezimaltrennzeichen bei Zahlen],
    [KOMMA], [`,`], [Trennzeichen bei Aufzählungen (Listen, Parameter)],
    [DOPPELPUNKT], [`:`], [Doppelpunkt], 
    [SEMIKOLON], [`;`], [Trennzeichen / Befehlsabschluss], 
    [NEUE_LINIE], [`\n`], [Zeilenumbruch (Separator)], 
    [ANFANG_LINIE], [`\r`], [Wagenrücklauf (Separator)], 
    [TAB], [`\t`], [Tabulator (Separator)], 
    [ANFANG_KOMMENTAR], [`«` _oder_ `/*`], [Beginn eines mehrzeiligen Kommentars], 
    [ENDE_KOMMENTAR], [`»` _oder_ `*/`], [Ende eines mehrzeiligen Kommentars], 
    [ANFANG_LINIE_KOMMENTAR], [`¶` _oder_ `//`], [Einzeiliger Kommentar bis zum Zeilenende], 
    [ANFÜGEN], [`↤` _oder_ `<+`], [Anfügen eines Elements an eine Liste], 
  )], 
  caption: [Liste der Operatoren und ihrem Nutzen in GEISS.\
    Quelle: Quellencode des Interpreters: /kern/operatoren.d]
)

== Liste der Schlüsselwörter
<liste_schlusselworter>

Unten finden Sie eine Tabelle mit allen Schlüsselwörtern mit ihrem internen
Namen, ihrer Syntax und ihrem Nutzen.
#figure(
  align(center)[#table(
    columns: (auto,) * 2 + (1fr,),
    inset: 6pt,
    [FALLS], [`falls`], [Bedingte Verzweigung],
    [SONST], [`sonst`], [Alternativzweig einer Verzweigung],
    [SOLANGE], [`solange`], [Bedingungsgesteuerte Schleife (while)],
    [WIEDERHOLE], [`wiederhole`], [Zählschleife: Wiederholt einen Block N Mal],
    [MAL], [`mal`], [Zusatzwort für die Zählschleife (`wiederhole N mal`)],
    [NICHT], [`nicht`], [Logische Negation einer Bedingung],
    [PRO], [`pro`], [Iterieren über Elemente oder Indizes],
    [VON], [`von`], [Herkunftsangabe für Iterationen],
    [BEENDE_FUNKTION], [`beende funktion`], [Vorzeitiges Beenden einer Funktion],
    [BEENDE_SCHLEIFE], [`beende schleife`], [Vorzeitiges Abbrechen einer Schleife (break)],
    [BEENDE_PROGRAMM], [`beende programm`], [Beendet das gesamte Programm bzw. die REPL-Sitzung],
  )], 
  caption: [Liste der Schlüsselwörter und ihrem Nutzen in GEISS.\
    Quelle: Quellencode des Interpreters: /kern/schlüsselwörter.d]
)


