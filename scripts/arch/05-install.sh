#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="

pacstrap /mnt base yubikey-manager yubikey-personalization pcsc-tools libu2f-host acpid dbus grub-efi-x86_64 efibootmgr lvm2

genfstab -U -p /mnt >> /mnt/etc/fstab

cat /mnt/etc/fstab

echo ""
echo "====================="
echo "Proceed with chapter 05: YubiKey Full Disk Encryption"