# KOOFORWAY-triple-screen-driver

[English](README.en.md)

Kernelmodul für den Laptop KOOFORWAY (Alder Lake-P, Intel Iris Xe, PCI `8086:46a6`). Es schaltet alle Bildschirme ein.

## Das Problem

Der Laptop hat drei Bildschirme: die Mitte und je einen Flügel links und rechts. Unter Windows laufen alle drei. Unter Linux bleiben nur die Mitte und ein Flügel an. Der andere Flügel bleibt dunkel, und der Kernel legt keinen Anschluss dafür an.

## Ursache

Das BIOS lässt Bit 2 in `SOUTH_CHICKEN1` (`ICP_SECOND_PPS_IO_SELECT`) aus. `i915` verwirft deshalb den zweiten internen Bildschirm an DDI B mit `unusable PPS, disabling eDP`. Das Modul setzt dieses Bit, bevor `i915` startet.

## Installation

Die Header des laufenden Kernels müssen installiert sein. Im Verzeichnis des Treibers:

```bash
sudo ./install.sh
```

Dasselbe macht `sudo make install`. Das Skript baut das Modul, kopiert es nach `/lib/modules/$(uname -r)/updates/`, legt `/etc/modprobe.d/i915-second-pps.conf` an, aktualisiert die Initrd und schreibt den GRUB-Eintrag für zwei Bildschirme, falls dort noch keiner mit `modprobe.blacklist=i915_second_pps` steht.

Danach neu starten. Im Log steht `i915_second_pps: SOUTH_CHICKEN1 0x901 -> 0x905`, und der zweite Flügel erscheint als `eDP-2`. Nach einem Kernel-Update `sudo ./install.sh` erneut ausführen.

## Entfernen

```bash
sudo ./uninstall.sh
```

Das entfernt Modul, Modprobe-Datei und den vom Installer geschriebenen GRUB-Eintrag. Ein vorher von Hand angelegter Eintrag bleibt stehen.

## Von Hand

### Bauen

```bash
make
```

### Installieren

```bash
sudo install -D -m 644 i915_second_pps.ko /lib/modules/$(uname -r)/updates/i915_second_pps.ko
sudo install -m 644 i915-second-pps.conf /etc/modprobe.d/i915-second-pps.conf
sudo depmod -a
sudo update-initramfs -u -k "$(uname -r)"
```

## Zurück zum Zustand mit zwei Bildschirmen

`modprobe.blacklist=i915_second_pps` lädt das Modul nicht. `i915` startet dann wie ohne den Treiber: Mitte und ein Flügel an, der andere Flügel dunkel. Der normale Menüeintrag bleibt der Start mit drei Bildschirmen.

### Einmalig ausprobieren

Im GRUB-Menü den normalen Eintrag wählen und `e` drücken. Ans Ende der Zeile, die mit `linux` beginnt, anhängen:

```text
modprobe.blacklist=i915_second_pps
```

Mit Strg+X oder F10 starten. Die Ergänzung gilt nur für diesen Start.

### Eigener Menüeintrag

Die Datei mit nano öffnen:

```bash
sudo nano /etc/grub.d/40_custom
```

Die Zeile `exec tail` bleibt stehen. Den folgenden Block ans Ende der Datei setzen. Kernel, Initrd und die übrige Kernelzeile müssen zum normalen Eintrag passen. Nur der Blacklist-Parameter kommt dazu:

```sh
menuentry 'KOOFORWAY, zwei Bildschirme' {
	load_video
	insmod gzio
	insmod part_gpt
	insmod ext2
	search --no-floppy --fs-uuid --set=root b7162e8c-fc38-46ec-a561-a1fa43beb125
	linux /boot/vmlinuz-6.17.7-061707-generic root=UUID=b7162e8c-fc38-46ec-a561-a1fa43beb125 ro i915.force_probe=46a6 i915.enable_psr=0 i915.edp_vswing=2 i915.panel_use_ssc=0 i915.debug=edp modprobe.blacklist=i915_second_pps
	initrd /boot/initrd.img-6.17.7-061707-generic
}
```

Speichern mit Strg+O und Enter, nano mit Strg+X verlassen. Danach das Menü neu schreiben:

```bash
sudo update-grub
```

Der Eintrag erscheint unten im Menü und bleibt über Neustarts erhalten. Nach einem Kernel-Update die Pfade `vmlinuz-…` und `initrd.img-…` in diesem Eintrag auf die neue Version setzen und `update-grub` erneut ausführen.
