#!/bin/bash
# Installiert die Belegung, deren Zeichen zur Beschriftung des Laptops passen.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
	echo "Bitte als root starten: sudo ./install.sh" >&2
	exit 1
fi

root=$(cd "$(dirname "$0")" && pwd)
marker="KOOFORWAY-triple-screen-driver"
xml=/usr/share/X11/xkb/rules/evdev.xml
lst=/usr/share/X11/xkb/rules/evdev.lst
kb=/etc/default/keyboard

install -d -m 755 /etc/xkb/symbols /usr/share/X11/xkb/symbols
install -m 644 "${root}/kooforway" /etc/xkb/symbols/kooforway
install -m 644 "${root}/kooforway" /usr/share/X11/xkb/symbols/kooforway

if ! grep -q '<name>kooforway</name>' "$xml"; then
	echo "Trage die Belegung in die Auswahlliste ein …"
	awk -v marker="$marker" '
		{
			line[NR] = $0
		}
		END {
			for (i = 1; i <= NR; i++) {
				if (!done && line[i] ~ /<layout>/ && line[i + 2] ~ /<name>de<\/name>/) {
					print "    <!-- " marker " -->"
					print "    <layout>"
					print "      <configItem>"
					print "        <name>kooforway</name>"
					print "        <shortDescription>de</shortDescription>"
					print "        <description>German (KOOFORWAY)</description>"
					print "        <countryList>"
					print "          <iso3166Id>DE</iso3166Id>"
					print "        </countryList>"
					print "        <languageList>"
					print "          <iso639Id>deu</iso639Id>"
					print "        </languageList>"
					print "      </configItem>"
					print "    </layout>"
					done = 1
				}
				print line[i]
			}
			if (!done) exit 1
		}
	' "$xml" > "${xml}.tmp"
	mv "${xml}.tmp" "$xml"
fi

if ! grep -q '^  kooforway ' "$lst"; then
	awk '
		/^  de / && !done {
			print "  kooforway       German (KOOFORWAY)"
			done = 1
		}
		{ print }
		END { if (!done) exit 1 }
	' "$lst" > "${lst}.tmp"
	mv "${lst}.tmp" "$lst"
fi

if [[ -f $kb ]]; then
	awk '
		BEGIN { layout = 0 }
		/^XKBLAYOUT=/ { print "XKBLAYOUT=\"kooforway\""; layout = 1; next }
		/^XKBVARIANT=/ { print "XKBVARIANT=\"\""; next }
		{ print }
		END { if (!layout) print "XKBLAYOUT=\"kooforway\"" }
	' "$kb" > "${kb}.tmp"
	mv "${kb}.tmp" "$kb"
fi

if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
	uid=$(id -u "$SUDO_USER")
	bus="unix:path=/run/user/${uid}/bus"
	sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key LayoutList kooforway
	sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key VariantList ""
	sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key Use true
	sudo -u "$SUDO_USER" kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true
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

echo "Tastaturbelegung installiert."
echo "In den Systemeinstellungen muss Belegungen aktivieren an bleiben und German (KOOFORWAY) in der Liste stehen."
echo "Ein Wechsel des Tastaturmodells schaltet die Belegung sonst ab."
