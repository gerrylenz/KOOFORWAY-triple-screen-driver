#!/bin/bash
# Entfernt Modul, Modprobe-Datei und den vom Installer geschriebenen GRUB-Eintrag.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
	echo "Bitte als root starten: sudo ./uninstall.sh" >&2
	exit 1
fi

kver=$(uname -r)
marker="# KOOFORWAY-triple-screen-driver"
custom=/etc/grub.d/40_custom

echo "Entferne Modul und Modprobe-Datei …"
rm -f "/lib/modules/${kver}/updates/i915_second_pps.ko"
rmdir "/lib/modules/${kver}/updates" 2>/dev/null || true
rm -f /etc/modprobe.d/i915-second-pps.conf
depmod -a "$kver"
update-initramfs -u -k "$kver"

if [[ -f $custom ]] && grep -qF "$marker" "$custom"; then
	echo "Entferne den GRUB-Eintrag …"
	awk -v marker="$marker" '
		$0 == marker { skip = 1; next }
		skip && $0 == "}" { skip = 0; next }
		skip { next }
		{ print }
	' "$custom" > "${custom}.tmp"
	mv "${custom}.tmp" "$custom"
	update-grub
else
	echo "Kein vom Installer geschriebener GRUB-Eintrag. Ein von Hand angelegter Eintrag bleibt stehen."
fi

echo "Entfernt. Neu starten, damit wieder nur zwei Bildschirme angehen."
