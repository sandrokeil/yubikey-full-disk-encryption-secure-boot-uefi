#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="

pvcreate /dev/mapper/cryptlvm
vgcreate MyVolGroup /dev/mapper/cryptlvm

lvcreate -L 20G MyVolGroup -n root
lvcreate -l 100%FREE MyVolGroup -n home

mkfs.ext4 /dev/MyVolGroup/root
mkfs.ext4 /dev/MyVolGroup/home

mount /dev/MyVolGroup/root /mnt
mkdir /mnt/home
mount /dev/MyVolGroup/home /mnt/home

echo ""
echo "====================="
echo "Proceed with chapter 04: Encrypted boot partition"