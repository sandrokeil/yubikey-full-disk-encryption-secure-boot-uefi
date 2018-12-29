# Install Arch Linux

> You can use the file `scripts/arch/05-install.sh`.

This chapter describes how to install a minimal Arch Linux. You will find an appropriated page in the Arch Wiki
[en](https://wiki.archlinux.org/index.php/installation_guide) / [de](https://wiki.archlinux.de/title/Anleitung_f%C3%BCr_Einsteiger).


## Basic stuff
The *base* package and some additional packages for the YubiKey and full disk encryption will be installed to the `/mnt` folder.
If you want to know more about the individual package, please take a look at the [Arch package site](https://www.archlinux.org/packages/).

```
pacstrap /mnt base yubikey-manager yubikey-personalization pcsc-tools libu2f-host acpid dbus grub-efi-x86_64 efibootmgr lvm2
```

## Generate fstab
The following command will generate the *fstab* entries of the currently mounted partitions.

```
genfstab -U -p /mnt >> /mnt/etc/fstab
```

Check it out with `cat /mnt/etc/fstab` and verify it.

## YubiKey Full Disk Encryption
Next step is to copy the [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption) folder
to the `/mnt` folder because it will be installed later. The YubiKey challenge is stored in a file to make it
available inside the new system. More on that later. Replace `[Your YubiKey password]` with your YubiKey password.

```
cp -r yubikey-full-disk-encryption /mnt/home/
echo "export YKFDE_CHALLENGE=$(printf '[Your YubiKey password]' | sha256sum | awk '{print $1}')" > /mnt/home/challenge.txt
```

Copy `/etc/ykfde.conf` to `/mnt/home` so you can use this file later in your new environment.

## Mount run folder

When running `grub-mkconfig` you will see the error `/run/lvm/lvmetad.socket: connect failed: No such file or directory`.
That's why the host `/run` folder must be available inside the `chroot` environment. This is prepared with the following
lines and finished later on.

```
mkdir /mnt/hostrun/
mount --bind /run /mnt/hostrun
```

## chroot

> You can use the file `scripts/arch/05-chroot.sh`.

It's time to switch into your new system with `arch-chroot /mnt` and prepare some stuff. After successfully changed root to
the new system, execute the following lines to make the hosts *lvm* available here for `grub-mkconfig`.

You will need the same packages like in chapter *01: Getting Started*.

```
pacman -Sy yubikey-manager yubikey-personalization pcsc-tools libu2f-host make json-c cryptsetup
```

```
mkdir /run/lvm
mount --bind /hostrun/lvm /run/lvm
```

Next step is to install the *yubikey-full-disk-encryption* helper scripts. If they are not already copied in your home
folder, you can it download from the GitHub repository [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption).

```
cd /home/yubikey-full-disk-encryption
make install
```

Copy `/home/ykfde.conf` to  `/etc/ykfde.conf` so you have your previous settings or configure the file as described
in chapter *Prepare YubiKey*. The YubiKey challenge will now be stored in the `ykfde.conf`
file. The environment variable with the YubiKey challenge is loaded into the environment so it can be set
into the `ykfde.conf` file with the command `sed`.

```
source /home/challenge.txt
sed -i "s/#YKFDE_CHALLENGE=\"/YKFDE_CHALLENGE=\"$YKFDE_CHALLENGE/g" /etc/ykfde.conf
```

Check that the YubiKey challenge was successfully saved to `/etc/ykfde.conf` with `cat /etc/ykfde.conf`.

## mkinitcpio
The next step is to prepare the `mkinitcpio.conf` to detect and unlock an encrypted partition at boot. Open the file with
`vi /etc/mkinitcpio.conf` and replace the *HOOKS* line with the following content.

> Don't add `encrypt` hook, because we ues ykfde and respect the order !!!

```
HOOKS=(base udev autodetect consolefont modconf block keymap lvm2 filesystems fsck keyboard ykfde)
```

Additionally the *ext4* module is needed. Add *ext4* to the *MODULES*. It should look like this line:

```
MODULES=(ext4)
```

### German users
German users have to configure german keyboard layout, otherwise YubiKey passphrase will be wrong.

```
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf
```

## GRUB
The next part is a bit tricky, because you have to figure out the correct device UUIDs. First, get a list of your device
IDs with `lsblk -f`. Alternative `blkid` can be used. It should look something like this:

```
NAME                  FSTYPE      LABEL UUID                                   MOUNTPOINT
nvme0n1
├─nvme0n1p1
├─nvme0n1p2           vfat              AB24-1550                              /boot/efi
├─nvme0n1p3           crypto_LUKS       434a512a-1b76-449e-8cb0-f93aee46e85c
│ └─cryptboot         ext4              5fe2b9c5-ac2b-4f6e-8f3e-5e45c45d0b02   /boot
└─nvme0n1p4           crypto_LUKS       a86c6534-6643-4afa-b3ae-c78a0a5dc50f
  └─cryptlvm          LVM2_member       heTIE6-0pLH-8J8Y-67T7-1vPW-4f1V-SqHeOA
    ├─MyVolGroup-root ext4              49a833a2-4a3b-4a1b-a7d9-75ab50910a8e   /
    └─MyVolGroup-home ext4              ec626537-c6a5-4df9-9ad9-3a344bc8c86f   /home
```

You will need the UUID from the *device 4th partition* (in this example *a86c6534-6643-4afa-b3ae-c78a0a5dc50f*) and the
UUID of *MyVolGroup-root* (in this example *49a833a2-4a3b-4a1b-a7d9-75ab50910a8e*). Open the GRUB config file with `vi /etc/default/grub`
and add these two lines with your UUIDs.

```
GRUB_CMDLINE_LINUX="cryptdevice=UUID=[4th partition UUID]:cryptlvm root=UUID=[MyVolGroup-root UUID]"
GRUB_ENABLE_CRYPTODISK=y
```

Finally the *GRUB_CMDLINE_LINUX* line should look like this line with your UUIDs.

```
GRUB_CMDLINE_LINUX="cryptdevice=UUID=a86c6534-6643-4afa-b3ae-c78a0a5dc50f:cryptlvm root=UUID=49a833a2-4a3b-4a1b-a7d9-75ab50910a8e"
```

## Generate initramfs
The last step is to generate a new *initramfs* and the GRUB boot loader. The first one is done with `mkinitcpio -p linux`
and the second one with the following lines (replace `[your device]` with your device e.g. `nvme0n1`):

```
grub-install --target=i386-pc --recheck /dev/[your device]
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

Add the `crypto_keyfile.bin` to the *crypttab*, otherwise you have to unlock the boot partition twice. Open the file with
`vi /etc/crypttab` and add the following line (replace `[UUID 3rd partition]` with the UUID of the 3rd partition e.g. `434a512a-1b76-449e-8cb0-f93aee46e85c `).

```
cryptboot      UUID=[UUID 3rd partition]    /crypto_keyfile.bin                    luks
```

It should look like this with your UUID of the 3rd partition.

```
cryptboot      UUID=434a512a-1b76-449e-8cb0-f93aee46e85c    /crypto_keyfile.bin                    luks
```

## Configure ykfde.conf
Open the file with `vi /etc/ykfde.conf` and enable/set `YKFDE_LUKS_NAME="cryptlvm"` and  `YKFDE_DISK_UUID=[4th partition UUID]`
(replace `[4th partition UUID]` with the UUID of the 4th partition e.g. `a86c6534-6643-4afa-b3ae-c78a0a5dc50f`).
Feel free to modify it to your needs e.g. enable TRIM (but be warned, there are potential security implications) support.
It should look something like this

```ini
### Configuration for 'yubikey-full-disk-encryption'.
### Remove hash (#) symbol and set non-empty ("") value for chosen options to
### enable them.

### *REQUIRED* ###

# Set to non-empty value to use 'Automatic mode with stored challenge (1FA)'.
YKFDE_CHALLENGE="8fa0acf6233b92d2d48a30a315cd213748d48f28eaa63d7590509392316b3016"

# Use 'Manual mode with secret challenge (2FA)'.
#YKFDE_CHALLENGE_PASSWORD_NEEDED="1"

# YubiKey slot configured for 'HMAC-SHA1 Challenge-Response' mode.
# Possible values are "1" or "2". Defaults to "2".
YKFDE_CHALLENGE_SLOT="2"

### OPTIONAL ###

# UUID of device to unlock with 'cryptsetup'.
# Leave empty to use 'cryptdevice' boot parameter.
YKFDE_DISK_UUID="a86c6534-6643-4afa-b3ae-c78a0a5dc50f"

# LUKS encrypted volume name after unlocking.
# Leave empty to use 'cryptdevice' boot parameter.
YKFDE_LUKS_NAME="cryptlvm"

# Device to unlock with 'cryptsetup'. If left empty and 'YKFDE_DISK_UUID'
# is enabled this will be set as "/dev/disk/by-uuid/$YKFDE_DISK_UUID".
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_DEV=""

# Optional flags passed to 'cryptsetup'. Example: "--allow-discards" for TRIM
# support. Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_OPTIONS=""

# Number of times to try assemble 'ykfde passphrase' and run 'cryptsetup'.
# Defaults to "5".
#YKFDE_CRYPTSETUP_TRIALS="5"

# Number of seconds to wait for inserting YubiKey, "-1" means 'unlimited'.
# Defaults to "30".
#YKFDE_CHALLENGE_YUBIKEY_INSERT_TIMEOUT="30"

# Number of seconds to wait after successful decryption.
# Defaults to empty, meaning NO wait.
#YKFDE_SLEEP_AFTER_SUCCESSFUL_CRYPTSETUP=""

# Verbose output. It will print all secrets to terminal.
# Use only for debugging.
#DBG="1"
```

## Test it
It's time to check your settings with a graceful reboot. If you have done all things right, you will be asked for your
boot partition password to see the GRUB boot menu and after that, the YubiKey password with YubiKey touch button to unlock
the root partition.

Good luck! Don't worry if something doesn't work, simply boot from the Arch Linux medium, install the necessary software
to mount your encrypted partitions and check the configs. Maybe an UUID is wrong.

Now you can setup your Arch Linux e.g. create own user or add additional stuff [en](https://wiki.archlinux.org/index.php/installation_guide) / [de](https://wiki.archlinux.de/title/Anleitung_f%C3%BCr_Einsteiger).
The next chapter describes how to setup UEFI secure boot. The last piece to bullet proof your full disk encryption.