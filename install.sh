#!/bin/bash
# Installiert das Modul, die Modprobe-Datei, die Initrd und den GRUB-Eintrag.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
	echo "Bitte als root starten: sudo ./install.sh" >&2
	exit 1
fi

root=$(cd "$(dirname "$0")" && pwd)
kver=$(uname -r)
marker="# KOOFORWAY-triple-screen-driver"
custom=/etc/grub.d/40_custom

if [[ ! -d /lib/modules/${kver}/build ]]; then
	echo "Die Header für den laufenden Kernel fehlen: linux-headers-${kver}" >&2
	exit 1
fi

echo "Baue das Modul für ${kver} …"
if command -v gcc-15 >/dev/null 2>&1; then
	make -C "$root" all
else
	make -C "$root" all CC=gcc
fi

echo "Installiere Modul und Modprobe-Datei …"
install -D -m 644 "${root}/i915_second_pps.ko" "/lib/modules/${kver}/updates/i915_second_pps.ko"
install -m 644 "${root}/i915-second-pps.conf" /etc/modprobe.d/i915-second-pps.conf
depmod -a "$kver"
update-initramfs -u -k "$kver"

if [[ ! -f /boot/vmlinuz-${kver} || ! -f /boot/initrd.img-${kver} ]]; then
	echo "Kernel oder Initrd fehlt unter /boot für ${kver}." >&2
	exit 1
fi

cmdline=$(sed -E 's/^BOOT_IMAGE=[^[:space:]]+[[:space:]]+//' /proc/cmdline)
case "$cmdline" in
	*modprobe.blacklist=i915_second_pps*) ;;
	*) cmdline="${cmdline} modprobe.blacklist=i915_second_pps" ;;
esac
uuid=$(findmnt -no UUID /)

block=$(cat << EOF

${marker}
menuentry 'KOOFORWAY, zwei Bildschirme' {
	load_video
	insmod gzio
	insmod part_gpt
	insmod ext2
	search --no-floppy --fs-uuid --set=root ${uuid}
	linux /boot/vmlinuz-${kver} ${cmdline}
	initrd /boot/initrd.img-${kver}
}
EOF
)

if grep -qF "$marker" "$custom"; then
	echo "Aktualisiere den vorhandenen GRUB-Eintrag …"
	awk -v marker="$marker" '
		$0 == marker { skip = 1; next }
		skip && $0 == "}" { skip = 0; next }
		skip { next }
		{ print }
	' "$custom" > "${custom}.tmp"
	printf '%s\n' "$block" >> "${custom}.tmp"
	mv "${custom}.tmp" "$custom"
	update-grub
elif grep -q 'modprobe.blacklist=i915_second_pps' "$custom"; then
	echo "In ${custom} steht schon ein Eintrag mit der Blacklist. Er bleibt unverändert."
else
	echo "Schreibe den GRUB-Eintrag für zwei Bildschirme …"
	printf '%s\n' "$block" >> "$custom"
	update-grub
fi

echo "Installation fertig. Neu starten, damit alle drei Bildschirme angehen."
