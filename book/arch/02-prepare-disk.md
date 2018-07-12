# Prepare Disks

You have [different choices](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system "dm-crypt/Encrypting an entire system") to setup encryption.
This chapter describes [LVM on LUKS with encrypted boot partition](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_.28GRUB.29 "Encrypted boot partition (GRUB)").
Because we want to unlock all volumes at once.

List your disks with `lsblk` and run `gdisk /dev/[your disk]` e.g. `gdisk /dev/nvme0n1`. You can take a look at the 
`gdisk` Arch Wiki [en](https://wiki.archlinux.org/index.php/Fdisk#gdisk) / [de](https://wiki.archlinux.de/title/GPT#Partitionieren_mit_gdisk)

> It's crucial to use `gdisk` because GPT is needed for UEFI boot.

Please create 4 partition like described in the Arch Wiki above with `gdisk`. Use the codes for the partition type.
Don't format the partitions at this time, we will do it later with the YubiKey. It should look similar like this.

```
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048            4095   1024.0 KiB  EF02  BIOS boot partition
   2            4096         1232895   600.0 MiB   EF00  EFI System
   3         1232896         2461695   600.0 MiB   8300  Linux filesystem
   4         2461696      2000409230   952.7 GiB   8E00  Linux LVM
```

The second partition contains the EFI System and must be of type FAT32. Format the second partition e.g. `/dev/nvme0n1p2` with: 

```
mkfs.fat -F32 /dev/[disk 2nd partition]
```

The next chapter describes how to prepare the YubiKey.
