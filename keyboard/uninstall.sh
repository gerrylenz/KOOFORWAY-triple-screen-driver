#!/bin/bash
# Entfernt die KOOFORWAY-Tastaturbelegung und stellt Deutsch wieder her.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
	echo "Bitte als root starten: sudo ./uninstall.sh" >&2
	exit 1
fi

marker="KOOFORWAY-triple-screen-driver"
xml=/usr/share/X11/xkb/rules/evdev.xml
lst=/usr/share/X11/xkb/rules/evdev.lst
kb=/etc/default/keyboard

rm -f /etc/xkb/symbols/kooforway /usr/share/X11/xkb/symbols/kooforway
rmdir /etc/xkb/symbols /etc/xkb 2>/dev/null || true

if [[ -f $xml ]] && grep -q '<name>kooforway</name>' "$xml"; then
	awk -v marker="$marker" '
		$0 == "    <!-- " marker " -->" { next }
		/<layout>/ { inlayout = 1; buf = $0 ORS; next }
		inlayout {
			buf = buf $0 ORS
			if ($0 ~ /<\/layout>/) {
				if (buf !~ /<name>kooforway<\/name>/) printf "%s", buf
				inlayout = 0
				buf = ""
			}
			next
		}
		{ print }
	' "$xml" > "${xml}.tmp"
	mv "${xml}.tmp" "$xml"
fi

if [[ -f $lst ]]; then
	grep -v '^  kooforway ' "$lst" > "${lst}.tmp" || true
	mv "${lst}.tmp" "$lst"
fi

if [[ -f $kb ]] && grep -q '^XKBLAYOUT="kooforway"' "$kb"; then
	sed -i 's/^XKBLAYOUT="kooforway"/XKBLAYOUT="de"/' "$kb"
fi

if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
	uid=$(id -u "$SUDO_USER")
	bus="unix:path=/run/user/${uid}/bus"
	current=$(sudo -u "$SUDO_USER" kreadconfig6 --file kxkbrc --group Layout --key LayoutList || true)
	if [[ $current == kooforway ]]; then
		sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key LayoutList de
		sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key VariantList ""
	fi
	if [[ -S /run/user/${uid}/bus ]]; then
		sudo -u "$SUDO_USER" env \
			DBUS_SESSION_BUS_ADDRESS="$bus" \
			XDG_RUNTIME_DIR="/run/user/${uid}" \
			dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig || true
		sudo -u "$SUDO_USER" env \
			DBUS_SESSION_BUS_ADDRESS="$bus" \
			XDG_RUNTIME_DIR="/run/user/${uid}" \
			qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure || true
	fi
fi

echo "Tastaturbelegung entfernt. Es gilt wieder die normale deutsche Belegung."
