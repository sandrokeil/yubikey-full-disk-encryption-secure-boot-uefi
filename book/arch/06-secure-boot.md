# Setup secure boot

This chapter describes how to configure secure boot because no one should modify the bootloader or boot from another medium. 
Gerke Max Preussner describes this very detailed in his post [Fully Encrypted ArchLinux with Secure Boot on Yoga 920](https://gmpreussner.com/reference/fully-encrypted-archlinux-with-secure-boot-on-yoga-920?#secureboot)
Please read his chapter about secure boot and come back to enable it.

## UEFI setup mode
To create own UEFI keys UEFI secure boot must be set into setup mode in BIOS. Restart the computer and enter BIOS setup.

1. Navigate to the **Security** page
1. Go to Set **Administrator/Supervisor Password** and enter a strong password
1. Go to **Reset to Setup Mode**, press Enter and select Yes
1. Save the changes and exit BIOS Setup

The preloaded secure boot keys for Microsoft/OEM are now deleted. You can restore it if needed.

## Setup cryptboot
Download or copy [xmikos/cryptboot](https://github.com/xmikos/cryptboot) to your home folder. To install *cryptboot* some
packages are required. Let's install them.

```
pacman -S binutils fakeroot
```

Next step is to install it without checksum check. Enter the *cryptboot* folder and execute

> You can use *ArchLinux* as name

```
makepkg -si --skipchecksums
```

Almost finished. The last step is to generate and enroll the new keys. This is easy with the following commands:

```
cryptboot-efikeys create
cryptboot-efikeys enroll
cryptboot update-grub
```

## Pacman hooks
To auto sign the kernel after an upgrade it's handy to have a [pacman hook for signing the kernel](https://wiki.archlinux.org/index.php/Secure_Boot#Signing_kernel_with_pacman_hook). Paste
Open the file with `/etc/pacman.d/hooks/98-secureboot.hook` and put these lines in it.

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Signing Kernel for SecureBoot - Update GRUB
When = PostTransaction
Exec = /usr/bin/cryptboot update-grub
```

## Enable UEFI secure boot
If you encountered no errors you can now enable UEFI secure boot. Restart the computer and enter BIOS setup.
                                                                  
1. Navigate to the **Security** page
1. Go to **Secure Boot** and enable it
1. Save the changes and exit BIOS Setup

Try to boot from an USB stick. It should not be possible anymore. If you need to boot from an other medium, disable
secure boot.
