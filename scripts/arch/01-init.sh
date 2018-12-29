#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="
pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make json-c cryptsetup

systemctl start pcscd.service

ykman list

lsblk

echo ""
echo "====================="
echo "Proceed with chapter 02: Prepare disks"