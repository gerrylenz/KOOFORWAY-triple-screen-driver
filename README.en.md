# KOOFORWAY-triple-screen-driver

[Deutsch](README.md)

Kernel module for the KOOFORWAY laptop (Alder Lake-P, Intel Iris Xe, PCI `8086:46a6`). It turns on all of the displays.

## The problem

The laptop has three displays: one in the center and one wing on each side. Windows drives all three. Linux keeps only the center and one wing. The other wing stays dark, and the kernel never creates a connector for it.

## Cause

The BIOS leaves bit 2 of `SOUTH_CHICKEN1` (`ICP_SECOND_PPS_IO_SELECT`) clear. `i915` then drops the second internal display on DDI B with `unusable PPS, disabling eDP`. This module sets that bit before `i915` starts.

## Build

```bash
make
```

The headers for the running kernel must be installed.

## Install

```bash
sudo install -D -m 644 i915_second_pps.ko /lib/modules/$(uname -r)/updates/i915_second_pps.ko
sudo install -m 644 i915-second-pps.conf /etc/modprobe.d/i915-second-pps.conf
sudo depmod -a
sudo update-initramfs -u
```

Reboot afterwards. The log should contain `i915_second_pps: SOUTH_CHICKEN1 0x901 -> 0x905`, and the second side panel shows up as `eDP-2`.

## Back to two displays

Append this to the kernel command line:

```text
modprobe.blacklist=i915_second_pps
```
