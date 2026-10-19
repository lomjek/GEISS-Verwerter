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

// Titel
#align(center)[
  #text(size: 2em, weight: "extrabold")[Dokumentation für]\
  #text(size: 2em, weight: "bold")[GEISS,] \
  #text(size: 1.5em)[eine interessante, sichere Sprache] \
]

// Einleitung
GEISS ist eine Programmiersprache, welche ich für meine Maturaarbeit implementiert habe. Es ist eine interpretierte Sprache. Die Variablen werden wie in Lisp#sub[1] 
gespeichert. Anderes Dokument, etc...

Diese Dokumentation ist die eigentliche, offizielle Dokumentation, welche ich führe. Sie sollte immer für den Release aktuell sein und mit dem Code übereinstimmen. Falls das nicht der Fall ist, dann 

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
Hier ist noch eine Liste von allen Methoden, welche schon in der Sprache eigebaut sind. Ich gebe nur ihre Signature und beschreibe, was sie macht...

= Zahlen und Listen

Vielleicht ist das nicht so spannend für nicht technische Leute, aber wenn jemand
mit GEISS programmiert und sich nicht sicher ist, ob der Fehler an ihm liegt, oder
an meiner Implementation von GEISS, dann können sich folgende Listen möglicherweise
als sehr nützlich auszeichnen.

== Liste der Operatoren
<liste_operatoren>

Unten finden Sie eine Tabelle mit allen Operatoren mit ihrem internen
Namen, ihrem Charakter und ihrem Nutzten.
#figure(
  align(center)[#table(
    columns: (auto,) * 2 + (1fr,),
    inset: 6pt,
    [PUNKT], [`.`], [Nachkommastellen bei Zahlen],
    [KOMMA], [`,`], [Aufzählungen bei Listen],
    [PLUS], [`+`], [Addition von Werten], 
    [MINUS], [`-`], [Subtraktion von Werten],
    [MAL], [`*`], [Multiplikation von Werten],
    [DURCH], [`/`], [Division von Werten], 
    [RÜCK_PFEIL], [`←` _oder_ `<-`], [Setzen von Variablen], 
    [VOR_PFEIL], [`→` _oder_ `->`], [Deklaration von Rückgabe der Funktionen], 
  )], 
  caption: [Liste der Operatoren und ihrem Nutzen in GEISS.\
    Quelle: Quellencode des Interpreters: /kern/operatoren.d]
)

== Liste der Schlüsselwörter
<liste_schlusselworter>

