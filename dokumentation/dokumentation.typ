#set par(
  justify: true,
)

#set text(
  font: "New Computer Modern",
  lang: "de",
  region: "ch",
  size: 11pt,
)

GEISS \(Version MUTSANAS\[Alpha\]) - Dokumentation

#align(center)[
  #text(size: 2em, weight: "extrabold")[Dokumentation für]\
  #text(size: 2em, weight: "bold")[GEISS,] \
  #text(size: 1.5em)[eine interessante, sichere Sprache] \
]

// Table of Contents
#outline(indent: auto)

= Lesen der Dateien
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

= Liste der Operatoren
<liste_operatoren>

Unten finden Sie eine Tabelle mit allen Operatoren mit ihrem internen
Namen, ihrem Charakter und ihrem Nutzten.
#figure(
align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [PUNKT],
  [.],
  [Nachkommastellen bei Zahlen],
  [KOMMA],
  [,],
  [Aufzählungen bei Listen],
  [PLUS],
  [+],
  [Addition von Werten],
  [MINUS],
  [-],
  [Subtraktion von Werten],
  [MAL],
  [\*],
  [Multiplikation von Werten],
)]
)

Ich habe ein Bisschen ein Motivationstief...
