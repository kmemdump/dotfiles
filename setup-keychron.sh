#!/usr/bin/env bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/70-keychron.rules"
RULE_CONTENT='KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0666"'

echo "Creating Keychron udev rule at ${RULE_FILE}..."
echo "${RULE_CONTENT}" | sudo tee "${RULE_FILE}" > /dev/null

echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=hidraw --action=add

echo ""
echo "Done! Please unplug and replug your Keychron keyboard (in Cable mode)."
read -rp "Press Enter after replugging to verify permissions..."

echo ""
echo "Current /dev/hidraw* permissions (look for crw-rw-rw-):"
ls -l /dev/hidraw*
