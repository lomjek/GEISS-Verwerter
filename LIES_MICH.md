# GEISS, eine interessante, sichere Programmiersprache!

Dateien beginnend mit _ut sind unit tests. Sie sind weder wichtig noch ge-
winnerbringend für das Projekt. Sie sind einfach dazu da, damit ich weiss,
dass ich keine Denkfehler gemacht habe.

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

**

Wenn sie alle diese Sachen installiert haben, navigieren Sie in ihrem **Terminal** 
in den Ordner dieses Projektes hinein und führen Sie folgenden Befehl aus:

```sh
dub build -b release
```