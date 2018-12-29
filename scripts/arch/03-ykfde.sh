#!/usr/bin/env bash
set -e

SCRIPT_NAME=`basename "$0"`
echo "=========== ${SCRIPT_NAME} ==========="

curl -L https://github.com/agherzan/yubikey-full-disk-encryption/archive/master.zip | bsdtar -xvf - -C .
cd yubikey-full-disk-encryption-master
make install

echo ""
echo "====================="
echo "Proceed with chapter 03: Prepare 2nd slot"