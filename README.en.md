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

`modprobe.blacklist=i915_second_pps` keeps the module from loading. `i915` then starts as it did without this driver: the center and one wing on, the other wing dark. The normal menu entry remains the boot with three displays.

### Try it once

In the GRUB menu, select the normal entry and press `e`. At the end of the line that starts with `linux`, append:

```text
modprobe.blacklist=i915_second_pps
```

Boot with Ctrl+X or F10. The addition applies only to this boot.

### A separate menu entry

Open the file with nano:

```bash
sudo nano /etc/grub.d/40_custom
```

Leave the `exec tail` line in place. Put the following block at the end of the file. The kernel, initrd, and the rest of the kernel command line must match the normal entry. Only the blacklist parameter is added:

```sh
menuentry 'KOOFORWAY, two displays' {
	load_video
	insmod gzio
	insmod part_gpt
	insmod ext2
	search --no-floppy --fs-uuid --set=root b7162e8c-fc38-46ec-a561-a1fa43beb125
	linux /boot/vmlinuz-6.17.7-061707-generic root=UUID=b7162e8c-fc38-46ec-a561-a1fa43beb125 ro i915.force_probe=46a6 i915.enable_psr=0 i915.edp_vswing=2 i915.panel_use_ssc=0 i915.debug=edp modprobe.blacklist=i915_second_pps
	initrd /boot/initrd.img-6.17.7-061707-generic
}
```

Save with Ctrl+O and Enter, then leave nano with Ctrl+X. Then rebuild the menu:

```bash
sudo update-grub
```

The entry shows up at the bottom of the menu and stays across reboots. After a kernel update, change the `vmlinuz-…` and `initrd.img-…` paths in this entry to the new version and run `update-grub` again.
