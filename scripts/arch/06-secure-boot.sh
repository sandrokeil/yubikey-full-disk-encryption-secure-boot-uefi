#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="

pacman -Sy binutils fakeroot

curl -L https://github.com/xmikos/cryptboot/archive/master.zip | bsdtar -xvf - -C .
cd cryptboot-master

makepkg -si --skipchecksums

cryptboot-efikeys create
cryptboot-efikeys enroll
cryptboot update-grub

echo ""
echo "====================="
echo "Proceed with chapter 06: Pacman hooks"