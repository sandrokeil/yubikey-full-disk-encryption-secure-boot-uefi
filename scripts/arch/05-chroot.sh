#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="

pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make json-c cryptsetup

mkdir -p /run/lvm
mount --bind /hostrun/lvm /run/lvm

cd /home/yubikey-full-disk-encryption-master
make install

cp /home/ykfde.conf /etc/ykfde.conf

source /home/challenge.txt
sed -i "s/#YKFDE_CHALLENGE=\"/YKFDE_CHALLENGE=\"$YKFDE_CHALLENGE/g" /etc/ykfde.conf

cat /etc/ykfde.conf

echo ""
echo "====================="
echo "Proceed with chapter 05: mkinitcpio"