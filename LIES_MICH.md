# GEISS, eine imperative, starke (Programmier-)Sprache!

![GEISS](./kunst/GEISS-2.png)

## Was ist GEISS?

GEISS ist eine Programmiersprache, welche ich erfunden habe. Ich habe einen
Interpreter geschrieben, welchen ich hier, auf GitHub veröffentlicht habe.
Für den Interpreter habe ich die Sprache "D" benutzt. Grund dafür ist, dass
sie schnell läuft, aber trotzdem sehr angenehm zu schreiben ist.

Der Interpreter ist meine Maturitätsarbeit. Ich gehe an die Kantonsschule
Zürich Nord und wir mussten zum Abschluss der Schule eine eigenständige
grössere Arbeit schreiben. Das Projekt dauerte ein knappes Jahr.
Ich hatte sehr viel Freude an diesem Projekt. Innerhalb der Maturitätsarbeit
konnte ich die Version Alpha.1 fertigstellen.

## Wie kann ich GEISS benutzten?

Sie können sich entweder ein vorgebautes Release holen, auf der rechten
Seite in GitHub, oder sich den Interpreter selber bauen. Wenn man diese
Datei hat, kann man sie direkt ausführen. So kommt man in ein REPL, in
welchem man sich mit der Sprache vertraut machen kann.

Für grössere Projekte empfiehlt es sich, eine Datei zu erstellen
(Es wäre toll, wenn sie auf ".geiss" endet).

Man kann sie dann ausführen wie folgt: 

```sh
./geiss <Dateipfad>
```

## Hallo, Welt!

```geiss
schreibe("Hallo, Welt!") 
```

Für mehrere Beispiele und für eine Anleitung, schauen sie das PDF im 
Ordner "dokumentation/" an.

## Bauen des Projektes

Um aus diesem Quellencode ein benutzbares, ausführbares Programm zu machen, 
brauchen Sie ein paar Programme. Ich kann hier nur die Anleitung für Debian 
Systeme hinterlegen, da ichh andere Systeme nicht kenne.

**build-essential**

Dies ist eine Sammlung von Bibliotheken, welche notwendig sind für das bauen 
von allen Projekten. Drin ist die *stdc* und andere grundlegende Sachen
enthalten. Installieren kann man es wie folgt:

```sh
sudo apt install build-essential
```

**ldc**

Dies ist der tatsächliche compiler für die D Sprache. Man braucht ihn für
das kompilieren von allen .d Dateien. Es gibt auch andere D-Compiler, aber
für sie werde ich jetzt keine Anleitung schreiben. Alle schritte sollten
auch mit anderen Compilern funktionieren.

```sh
sudo apt install ldc2
```

**dub**

Das ist eine tolle Sache. Anstelle davon, dass man manuell jedes der Dateien zu
einem Objekt macht und sie dann alle manuell linkt, macht es das einfach für dich.

```sh
sudo apt install dub
```

Wenn sie alle diese Sachen installiert haben, navigieren Sie in ihrem **Terminal** 
in den Ordner dieses Projektes hinein und führen Sie folgenden Befehl aus:

```sh
dub build -b release
```
