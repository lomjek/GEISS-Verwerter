# GEISS, eine interessante, sichere Programmiersprache!

Dateien beginnend mit _ut sind unit tests. Sie sind weder wichtig noch ge-
winnerbringend für das Projekt. Sie sind einfach dazu da, damit ich weiss,
dass ich keine Denkfehler gemacht habe.

## Über das Projekt

Ich gehe in Zürich zur Schule und hier mussten wir eine Maturaarbeit zum
Abschluss der Schule schreiben. Man konnte wählen, was einem das Herz be-
gehrte und ich hatte schön länger den Wunsch, einmal in meinem Leben eine
Programmiersprache zu bauen. 

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