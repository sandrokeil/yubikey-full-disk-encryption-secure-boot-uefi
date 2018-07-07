# YubiKey Full Disk Encryption

This repository contains a step-by-step tutorial to create a full disk encryption setup with two factor 
authentication (2FA) via [YubiKey](https://yubico.com/products/yubikey-hardware/). It contains:

- YubiKey encrypted root and home folder
- Encrypted `/boot` partition
- UEFI Secure boot (self signed boot loader)

Currently supported Linux:

- Arch Linux 

## Why
It took me several days to figure out how to set up a fully encrypted machine with 2FA. This guide should help
others to get it done in minutes (hopefully). There exists a plenty bunch of tutorials but no one contains a step-by-step 
guide to get the above things done.
