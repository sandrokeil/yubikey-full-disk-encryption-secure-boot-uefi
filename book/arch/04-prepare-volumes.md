# Prepare Volumes

> You can use the file `scripts/arch/04-prepare-volumes.sh`

Please take a look at the Arch Wiki page [Preparing the logical volumes](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_logical_volumes "preparing the logical volumes")
to create `/` and `/home` directory/partitions. In short you do this (without swap).

> The filesystem *ext4* is used.

```
pvcreate /dev/mapper/cryptlvm
vgcreate MyVolGroup /dev/mapper/cryptlvm

lvcreate -L 20G MyVolGroup -n root
lvcreate -l 100%FREE MyVolGroup -n home

mkfs.ext4 /dev/MyVolGroup/root
mkfs.ext4 /dev/MyVolGroup/home

mount /dev/MyVolGroup/root /mnt
mkdir /mnt/home
mount /dev/MyVolGroup/home /mnt/home
```

## Encrypted boot partition

The last volume is `/boot` which should also be encrypted. You can not use a YubiKey here, but it is protected with a password.
The Arch Wiki page [Preparing the boot partition](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_boot_partition_5 "Preparing the boot partition")
describes this in more detail. The `efi` partition will be mounted to `/boot/efi`.

Execute the following commands and replace `[device 3rd partition]` with the 3rd partition of your device e.g. `nvme0n1p3`
and replace `[device 2nd partition]` with the 2nd partition of your device e.g. `nvme0n1p2`.

The command `cryptsetup luksFormat` will prompt to enter your password to decrypt the boot partition at boot.
Use a strong password which you can remember.

> Be aware, GRUB boot loader uses US keyboard layout. German users should execute `loadkeys us` before running `cryptsetup` commands.

```
cryptsetup luksFormat /dev/[device 3rd partition]
cryptsetup open /dev/[device 3rd partition] cryptboot

ls /dev/mapper

mkfs.ext4 /dev/mapper/cryptboot

mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot

mkdir /mnt/boot/efi
mount /dev/[device 2nd partition] /mnt/boot/efi
```

## Keyfile for initramfs
[With a keyfile embedded in the initramfs](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#With_a_keyfile_embedded_in_the_initramfs "With a keyfile embedded in the initramfs")
you don't have to unlock the `/boot` partition twice. The `/boot` partition will be mounted if the system starts, so updates can be performed.

Create a randomized generated key file with the following lines and add this keyfile to the 3rd LUKS partition (replace `[device 3rd partition]` with the 3rd partition of your device e.g. `nvme0n1p3`).
The keyfile is copied in the root folder of the new Arch linux environment.

```
dd bs=512 count=4 if=/dev/urandom of=/mnt/crypto_keyfile.bin
chmod 000 /mnt/crypto_keyfile.bin
cryptsetup luksAddKey /dev/[device 3rd partition] /mnt/crypto_keyfile.bin
```

Now it's time to install Arch. You have made a great progress!