# KOOFORWAY-zweiter-bildschirm

Kernelmodul für den Laptop KOOFORWAY (Alder Lake-P, Intel Iris Xe, PCI `8086:46a6`). Es schaltet den zweiten internen Bildschirm ein.

Das BIOS lässt Bit 2 in `SOUTH_CHICKEN1` (`ICP_SECOND_PPS_IO_SELECT`) aus. `i915` verwirft deshalb den zweiten internen Bildschirm an DDI B mit `unusable PPS, disabling eDP`. Das Modul setzt dieses Bit, bevor `i915` startet.

## Bauen

```bash
make
```

Dafür müssen die Header des laufenden Kernels installiert sein.

## Installieren

```bash
sudo install -D -m 644 i915_second_pps.ko /lib/modules/$(uname -r)/updates/i915_second_pps.ko
sudo install -m 644 i915-second-pps.conf /etc/modprobe.d/i915-second-pps.conf
sudo depmod -a
sudo update-initramfs -u
```

Danach neu starten. Im Log steht `i915_second_pps: SOUTH_CHICKEN1 0x901 -> 0x905`, und der zweite Flügel erscheint als `eDP-2`.

## Zurück zum Zustand mit zwei Bildschirmen

An die Kernelzeile anhängen:

```text
modprobe.blacklist=i915_second_pps
```
