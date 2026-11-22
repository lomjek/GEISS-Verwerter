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
    #show regex("\b(variable|zahl|nzahl|natürliche|gzahl|ganze|text|liste|wahrheit)\b"): it => text(fill: rgb("#01007b"), it)

    #show regex("(<-|->|\b(falls|sonst|solange|nicht|wiederhole|mal|pro|von|beende|programm|schleife)\b)"): it => text(fill: rgb("#4f003d"), it, weight: "bold")

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
    #show regex("\b(funktion|variable|zahl|nzahl|natürliche|gzahl|ganze|text|liste|wahrheit)\b"): it => text(fill: rgb("#01007b"), it)

    #show regex("(<-|->|\b(falls|sonst|solange|nicht|wiederhole|mal|pro|von|beende|programm|schleife)\b)"): it => text(fill: rgb("#4f003d"), it, weight: "bold")

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
    #image("./Titelblatt.png");
  #text(size: 2em, weight: "bold")[GEISS,] \
  #text(size: 1.5em)[eine imperative, starke Sprache] \
]


// Einleitung
GEISS ist eine Programmiersprache, welche ich für meine Maturaarbeit an der Kantonsschule Zürich Nord implementiert habe.
Es ist eine interpretierte Sprache.

Diese Dokumentation ist die eigentliche, offizielle Dokumentation, welche ich führe. Sie sollte immer für den Release aktuell sein und mit dem Code übereinstimmen. Falls das nicht der Fall ist, dann schreiben Sie mir bitte.

#pagebreak()

// Table of Contents
#outline(indent: auto)

= Wie kann ich GEISS benützten?

GEISS ist eine interpretierte Sprache. Um GEISS also ausführen zu können, braucht man den Interpreter.
Der Interpreter ist erhältlich bei #link("https://github.com/lomjek/GEISS-Verwerter")[GitHub].
Man kann ihn aus dem Quellencode selber bauen (Anweisungen dazu sind auf GitHub).
Es gibt auch unter dem Tab release kompilierte Interpreter.

Man kann die Datei durch Doppelklicken öffnen. Das startet ein sogenanntes REPL.
Im REPL kann man sich mit der Sprache vertraut machen und Befehle ausprobieren.

Für grössere Projekte wäre es empfehlenswert, deb Quellencode in einer Datei zu speichern.
Es wäre toll, wenn die Datei mit ".geiss" endet.
Um dieses Programm auszuführen, muss man in einem Terminal das Programm aufrufen und ihm als erstes und einziges Argument den Dateipfad zuschicken:


```sh
./geiss <Dateipfad>
```

Wenn man mehrere Argumente hineinschreibt, oder einen invaliden Pfad aufschreibt, stürtzt das Programm ab.

== Hallo Welt!

#geiss_g[```geiss
schreibe("Hallo Welt!") 
```]

Das ist der einfachste Weg, um "Hallo Welt" in die Ausgabe zu schreiben.
Wenn man "Hallo Welt" zuerst in einer Variablen speicher möchte, bevor man es in 
die Ausgabe schreibt, geht man wie folgt vor:

#geiss_g[```geiss
text gruss <- "Hallo Welt!"

schreibe(gruss) 
```]

= Kommentare

In Geiss funktionieren die Kommentare, wie in der Sprache "C":

#geiss_g[```geiss
// Das hier ist ein Kommentar, welcher nur eine Linie lang geht...

/*
Das hier ist ein Kommentar, welcher sich über mehrere Linien ausbreiten kann.
*/
```]

= Datentypen
<Datentypen>

Es hat in GEISS wenige Datentypen, aber das ist absichtlich so.
Ich möchte noch Structs und Wörterbücher (Dictionaries) implementieren, aber sonst keine weiteren Datentypen. 
Die Sprache ist dynamisch, sie hat aber Überprüfungen während der Laufzeit, welche sicherstellen können, dass die Typen richtig sind.
Es ist stark typisiert, was heisst, dass man nicht einfach so Variablen umcasten kann (mit der Ausnahme von Zahlen).

== Zahlen

Für Zahlen hat es drei Datentypen: "zahl", welche alle rationale Zahlen enthalten kann; "gzahl", welche alle ganzen Zahlen enthalten kann und "nzahl" für natürliche Zahlen.

#geiss_g[```geiss
zahl z <- -1234.465
gzahl g <- -9
nzahl n <- 42
```]

Zahlentypen sind speziell, weil der Interpreter sie automatisch umändert, wenn er einen anderen Zahlentyp braucht.
Es gilt für diese erste Version, aber ich habe vor, es in weiteren Versionen rückgängig zu machen.

Wenn man eine rationale Zahl eingibt, aber eine ganze Zahl braucht, verwirft der Interpreter den Bruch.
Wenn man eine ganze Zahl eingibt und eine natürliche Zahl braucht, nimmt man den Betrag der Zahl.

#geiss_g[```geiss
gzahl gz <- -1234.465 // gz ist jetzt -1234
nzahl nz <- -42 // nz ist jetzt 42
```]

Für die Zahlen funktionieren die mathematischen Operationen +, -, \*, /.
Den Operator Hoch ("x hoch y") habe ich noch nicht implementiert.

== Text

Man kann Text mit "text" definieren. Ein Text kann Text enthalten.
Es gibt praktisch kein Limit für die Länge, welcher nicht durch das Hardware oder das Betriebssystem bedingt sind.
Man kann Text mit einfachen oder doppelten Quotes definieren, man kann auch Backslashes benutzten: #geiss[`"`], #geiss[`'`], #geiss[`\"`], #geiss[`\'`].

#geiss_g[```geiss
text var1 <- "Hallo"
text var2 <- 'Hallo'
text var3 <- \"Hallo\"
text var4 <- \'Hallo\' 
```]
Alle diese definitionen sind gütlig und gleich.

#geiss_g[```geiss
text var5 <- "Hallo\' // Nicht geschlossener String...
```]

Wenn man zwei Texte addiert, dann klebt man sie einfach zusammen:

#geiss_g[```geiss
"Hallo" + 'Hallo' = "HalloHallo" //Diese Aussage ist wahr...
```]

== Listen

Listen sind in meiner Sprache sehr flexibel:

#geiss_g[```geiss
liste sammlung <- [123, 345, 456, "Hallo", wahr]
```]

Solange eine Liste nicht typisiert ist, kann sie alle Datentypen enthalten. Eine Liste kann man typisieren wie folgt: 

#geiss_g[```geiss
liste[liste[text]] feld <- [
	["ts", "ks", "ds", "ts"],
	["bs", "bs", "bs", "bs"],
	["bw", "bw", "bw", "bw"],
	["tw", "dw", "kw", "tw"]
]
```]

Das Typisieren funktioniert auch rekursiv. 
Der Interpreter garantiert jetzt, dass alle Elemente die in der Liste "feld" sind, listen sind, welche text enthalten.

Wenn man zwei Listen addiert, dann werden die zwei Listen nacheinander zusammengefügt.

#geiss_g[```geiss
liste sammlung2 <- [123, 345] + [456, "Hallo", wahr]
```]

Die Liste "sammlung2" ist jetzt identisch zur Liste "sammlung" von weiter oben.

Um einer Liste ein Element hinzuzufügen, kann man den Operator "<+" benutzten.

#geiss_g[```geiss
[123, 345] <+ 456 // wird zu [123, 345, 456]
```]

== Wahrheiten

Wahrheiten können entweder "wahr" oder "falsch" sein. Man definiert sie so:

#geiss_g[```geiss
wahrheit x <- wahr
wahrheit y <- falsch
```]

Alle Operationen (wie +, - , \*, \/), welche man an Wahrheiten macht geben "falsch" zurück, weil man eigentlich an Wahrheiten keine Operationen machen soll.
Um wahrheiten zu negieren, schreibt man ein nicht davor. 

#geiss_g[```geiss
nicht wahr // Gibt falsch zurück.
```]

== Funktionen

Funktionen nehmen eine Eingabe, prozessieren diese und geben eine Ausgabe zurück.
Man kann für eine Funktion mehrere Parameter definieren, allerdings nur eine Ausgabe.

#geiss_g[```geiss
funktion name(variable eingabe, variable eingabe2) -> variable ausgabe
{ ... }
```]

Um eine Funktion abzurufen, schreibt man einfach

#geiss_g[```geiss
variable ret_val <- name(wahr, "y")
```]

Man kann Werte zurückgebe indem man sie in die Variable der Ausgabe schreibt:

#geiss_g[```geiss
funktion hallo() -> variable ausgabe
{
    ausgabe <- "Hallo"
}
```]
Immer, wenn man die Funktion abruft, gibt sie den Text "Hallo" zurück.

= Verzweigungen

Um mit Bedingungen den Code unterschiedliche Wege einschlagen zu lassen, benutzt man das Schlüsselwort "falls":

#geiss_g[```geiss
wahrheit bedingung <- wahr

falls bedingung {
    schreibe("Hallo!")
}
```]

Die Bedingung kann auch ein Vergleich sein, oder ein Funktionsaufruf, welcher eine Wahrheit zurückgibt.

Dieses Programm schreibt "Hallo!" in die Ausgabe:
#geiss_g[```geiss
falls nicht 2 = 3 {
    schreibe("Hallo!")
}
```]

Man kann auch "sonst" benutzten, als Gegenstück zu "falls":

#geiss_g[```geiss
falls 2 = 3 {
    schreibe("Mathe macht keinen Sinn!")
}
sonst {
    schreibe("Mathe macht Sinn!")
}
```]

Man kann auch "sonst" und "falls" kombinieren zu "sonst falls":

#geiss_g[```geiss
falls 2 > 3 {
    schreibe("2 > 3")
}
sonst falls 2 < 3 {
    schreibe("2 < 3")
}
sonst {
    schreibe("2 = 3")
}
```]

= Schleifen

In  Geiss kann man je nach Problem unterschiedliche Schleifen benutzten.

== Wiederhole

Wenn man einen Block Code einfach n-Mal wiederholen will, dann kan man die wiederhole-Schleife nutzten:

#geiss_g[```geiss
wiederhole 2 mal {
    schreibe("Hallo!")
}
```]

Schreibt zwei Mal "Hallo!" in die Ausgabe.

== Solange

Die "Solange"-Schleife läuft so lange die Bedingung wahr ist. Sobald die Bedingung falsch wird, gibt es keinen nächsten Durchlauf mehr.

#geiss_g[```geiss
wahrheit mw <- wahr
    
solange mw {
    schreibe("Hallo!")
    mw <- falsch
}
```]

Dieses Programm schreibt "Hallo!" in die Ausgabe, denn wen der Block zum ersten Mal fertig ausgeführt ist, ist die Bedingung nicht mehr wahr und die Schleife bricht ab.

== Pro-Von

Mit dieser Schlaufe kann man durch die Elemente einer Liste iterieren.

#geiss_g[```geiss
liste[nzahl] zahlen <- [12, 23, 34, 45, 56, 67, 78, 89]
    
pro nzahl nummer von zahlen {
    schreibe(nummer)
}
```]

Dieses Programm schreibt nacheinander alle Zahlen der Liste in die Ausgabe.

Wichtiges Detail: pro/von Schleifen erstellen keinen neuen Bereich, also darf die neue Variable (im oberen Fall "nzahl nummer") nicht den gleichen Namen wie schon eine früher Erstellte.

#geiss_g[```geiss
liste[nzahl] zahlen <- [12, 23, 34, 45, 56, 67, 78, 89]

nzahl nummer <- 0

pro nzahl nummer von zahlen { // Produziert einen Fehler
    schreibe(nummer)
}
```]

Das Programm produziert einen Fehler, weil die Variable "nummer" schon existiert.

= Signale

Signale sind ein Weg, um gewisse Blöcke vorzeitig zu beenden.
Es gibt drei Arten von Signalen:

#geiss_g[```geiss
beende programm
beende funktion
beende schleife
```]

Beende Programm beendet das Programm sofort und zwar egal, wo es aufgerufen wird.
Die anderen Beiden Signale beenden den innersten jeweiligen Block.

Wenn man "beende schleife" oder "beende programm" aufruft, man sich aber nicht in einer Schleife oder Funktion befindet, endet das Programm stumm.
Das wird in Zukünftigen Versionen auch geändert.

Ein kleines Beispiel:

#geiss_g[```geiss
funktion abc (text eingabe) -> wahrheit w
{   
    falls eingabe = "abc"
    {
        schreibe("abc!")
        w <- wahr
        beende funktion
    }
    
    schreibe("nöd abc!") // eingabe = abc -> Fn. schon oben beendet.
    w <- falsch
}

beende programm

schreibe("Hallo!") // Wird nie ausgeführt...
```]

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
funktion indizes(liste eingabe) -> liste indizes
```]

Gibt eine Liste mit den Indizes der übergebenen Liste zurück. (Es ist nütztlich für pro/von-Schleifen)

#geiss_g[```geiss
funktion indizes(liste eingabe) -> nzahl länge
```]

Gibt die Länge der eingegebenen Liste als natürliche Zahl zurück.

= Zahlen und Listen

Vielleicht ist das nicht so spannend für nicht technische Leute, aber wenn jemand
mit GEISS programmiert und sich nicht sicher ist, ob der Fehler an ihm liegt, oder
an meiner Implementation von GEISS, dann können sich folgende Listen möglicherweise
als sehr nützlich auszeichnen.

Der Interpreter für diese Version (Alpha.1) besteht aus 5'028 Zeilen Code.

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


