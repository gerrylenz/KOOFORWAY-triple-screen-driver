# Tastatur

[English](README.en.md)

Die Tasten dieses Laptops sind deutsch beschriftet, QWERTZ, und die Ziffern gelten ohne Umschalt. An drei Tasten steht in den Ecken etwas anderes als die normale deutsche Belegung liefert.

Die Ecken sind so gemeint: unten rechts ohne Zusatztaste, oben rechts mit Umschalt, unten links mit AltGr, oben links mit AltGr und Umschalt.

| Taste | ohne | Umschalt | AltGr | AltGr+Umschalt |
| --- | --- | --- | --- | --- |
| Komma | `,` | `;` | `,` | `<` |
| Punkt | `.` | `:` | `.` | `>` |
| Minus | `-` | `_` | `/` | `?` |

`/` liegt zusätzlich auf Umschalt+7, `?` zusätzlich auf Umschalt+ß. Das Tastaturmodell ändert die Zeichen nicht.

## Linux

Jede Zeile in ein Terminal eintippen oder hineinkopieren und mit Enter bestätigen. Wenn nach einem Passwort gefragt wird, tippen und Enter drücken. Dabei erscheinen keine Zeichen.

Im Ordner dieses Repositories:

```bash
cd keyboard
sudo ./install.sh
```

Die Belegung heißt danach **German (KOOFORWAY)**.

In den Systemeinstellungen unter Tastatur muss **Belegungen aktivieren** an bleiben und **German (KOOFORWAY)** in der Liste stehen. Ein Wechsel des Tastaturmodells schaltet die Belegung sonst ab. Dann `sudo ./install.sh` erneut ausführen.

Entfernen, zurück zur normalen deutschen Belegung:

```bash
sudo ./uninstall.sh
```

## Windows 11

Windows hat kein Tastaturmodell, das die Zeichen festlegt. Ausgangspunkt ist die deutsche Belegung. Geändert werden dieselben drei Tasten.

### 1. .NET Framework 3.5 einschalten

Die Suche öffnen, **Windows-Features aktivieren oder deaktivieren** eingeben und **.NET Framework 3.5 (enthält .NET 2.0 und 3.0)** aktivieren.

Ab Windows 11 Version 26H1 gibt es den Eintrag dort nicht mehr. Dann das eigenständige Installationsprogramm für .NET Framework 3.5 von Microsoft verwenden.

### 2. Den Keyboard Layout Creator installieren

Im Microsoft Download Center nach **Microsoft Keyboard Layout Creator 1.4** suchen, die Datei laden und installieren.

### 3. Die deutsche Belegung laden

Das Programm starten. **File**, dann **Load Existing Keyboard**, dann **German**.

### 4. Die drei Tasten ändern

Links die Zusatztaste wählen und danach die Taste auf der Abbildung anklicken. AltGr heißt im Programm **Ctrl+Alt**.

Kommataste: ohne alles `,`, Umschalt `;`, Ctrl+Alt `,`, Umschalt+Ctrl+Alt `<`.

Punkttaste: ohne alles `.`, Umschalt `:`, Ctrl+Alt `.`, Umschalt+Ctrl+Alt `>`.

Minustaste, die Taste mit `-` unten rechts: ohne alles `-`, Umschalt `_`, Ctrl+Alt `/`, Umschalt+Ctrl+Alt `?`.

### 5. Benennen und bauen

**Project**, dann **Properties**. Name zum Beispiel `Deutsch KOOFORWAY`, Sprache Deutsch.

**Project**, dann **Validate Layout**. Danach **Project**, dann **Build DLL and Setup Package**.

### 6. Installieren

Im erzeugten Ordner `setup.exe` ausführen. Danach Windows neu starten. Erst nach dem Neustart erscheint die Belegung in der Liste.

### 7. Auswählen

**Einstellungen**, **Zeit und Sprache**, **Sprache und Region**, bei Deutsch die Sprachoptionen öffnen, **Tastatur hinzufügen** und **Deutsch KOOFORWAY** wählen. Die normale deutsche Belegung kann dort entfernt werden.

Umschalten geht mit der Windows-Taste und der Leertaste.

Unter **Erweiterte Tastatureinstellungen** darf **Tastaturlayout des Geräts überschreiben** nicht auf eine andere Belegung zeigen. Sonst gilt wieder die normale deutsche Belegung.
