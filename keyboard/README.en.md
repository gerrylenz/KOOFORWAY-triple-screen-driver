# Keyboard

[Deutsch](README.md)

The keys on this laptop are printed for German, QWERTZ, and the digits work without Shift. Three keys print something in the corners that the plain German layout does not produce.

The corners mean: bottom right with no modifier, top right with Shift, bottom left with AltGr, top left with AltGr and Shift.

| Key | plain | Shift | AltGr | AltGr+Shift |
| --- | --- | --- | --- | --- |
| comma | `,` | `;` | `,` | `<` |
| period | `.` | `:` | `.` | `>` |
| minus | `-` | `_` | `/` | `?` |

`/` is also on Shift+7, and `?` is also on Shift+ß. The keyboard model does not choose the characters.

## Linux

Type each line into a terminal, or paste it, and press Enter. When a password is requested, type it and press Enter. Nothing is shown while you type.

From this repository:

```bash
cd keyboard
sudo ./install.sh
```

The layout is then called **German (KOOFORWAY)**.

In System Settings, under Keyboard, **Configure layouts** has to stay on and **German (KOOFORWAY)** has to stay in the list. Changing the keyboard model turns the layout off. Run `sudo ./install.sh` again if that happens.

Remove it and return to plain German:

```bash
sudo ./uninstall.sh
```

## Windows 11

Windows has no keyboard model that assigns the characters. Start from the German layout and change the same three keys.

### 1. Turn on .NET Framework 3.5

Open search, type **Turn Windows features on or off**, and enable **.NET Framework 3.5 (includes .NET 2.0 and 3.0)**.

Starting with Windows 11 version 26H1 that entry is gone. Use Microsoft’s standalone installer for .NET Framework 3.5 instead.

### 2. Install Keyboard Layout Creator

In the Microsoft Download Center, search for **Microsoft Keyboard Layout Creator 1.4**, download it, and install it.

### 3. Load the German layout

Start the program. Choose **File**, then **Load Existing Keyboard**, then **German**.

### 4. Change the three keys

Select the modifier on the left, then click the key in the picture. AltGr is shown as **Ctrl+Alt**.

Comma: plain `,`, Shift `;`, Ctrl+Alt `,`, Shift+Ctrl+Alt `<`.

Period: plain `.`, Shift `:`, Ctrl+Alt `.`, Shift+Ctrl+Alt `>`.

Minus, the key with `-` at the bottom right: plain `-`, Shift `_`, Ctrl+Alt `/`, Shift+Ctrl+Alt `?`.

### 5. Name it and build it

Choose **Project**, then **Properties**. Use a name such as `Deutsch KOOFORWAY` and the language German.

Choose **Project**, then **Validate Layout**. Then **Project**, then **Build DLL and Setup Package**.

### 6. Install

Run `setup.exe` in the folder that was created. Restart Windows. The layout appears in the list only after the restart.

### 7. Select it

Open **Settings**, **Time & language**, **Language & region**, open the language options for German, choose **Add a keyboard**, and select **Deutsch KOOFORWAY**. The plain German layout can be removed there.

Switch with the Windows key and the space bar.

Under **Advanced keyboard settings**, **Override for default input method** must not point at another layout. Otherwise plain German is used again.
