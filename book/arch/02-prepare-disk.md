# Prepare Disks

You have [different choices](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system "dm-crypt/Encrypting an entire system") to setup encryption.
This chapter describes [LVM on LUKS with encrypted boot partition](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_.28GRUB.29 "Encrypted boot partition (GRUB)").

List your disks with `lsblk` and run `gdisk /dev/[your disk]` e.g. `gdisk /dev/nvme0n1`. You can take a look at the 
`gdisk` Arch Wiki [en](https://wiki.archlinux.org/index.php/Fdisk#gdisk) / [de](https://wiki.archlinux.de/title/GPT#Partitionieren_mit_gdisk)

> It's crucial to use `gdisk` because GPT is needed for UEFI boot.

