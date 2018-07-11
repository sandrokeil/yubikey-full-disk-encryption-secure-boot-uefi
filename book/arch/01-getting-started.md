# Getting Started

For common stuff, the Arch Wiki is a good starting point. We need a bootable Arch Linux medium. Please take a look
at the Arch Installtion Guide [en](https://wiki.archlinux.org/index.php/installation_guide#Pre-installation "Download and boot the installation medium") / [de](https://wiki.archlinux.de/title/Anleitung_für_Einsteiger#Das_neueste_ISO-Abbild_beziehen "Das neueste ISO-Abbild beziehen"). 

Ok, you've create a bootable Arch Linux medium, now it's time to boot into the Arch Linux UEFI system.

German users should execute `loadkeys de` (QWERTZ keyboard layout) in the tty prompt first.

Let's install minimal packages to get started with our full disk encryption with YubiKey.

```
pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make json-c cryptsetup
```

Now we must start the [smartcard service](https://wiki.archlinux.org/index.php/Smartcards "Smartcards")

```
systemctl start pcscd.service
```

and our connected YubiKey should be listed with

```
ykman list
```

That's it, now let's go over to the next chapter which describes how to prepare disks.
