# Prepare YubiKey

> You can use the file `scripts/arch/03-ykfde.sh`.

Download or mount [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption) and install it
in your Arch Linux Live environment. This is needed because we will format the 4th partition with YubiKey.

## Installation
Open the *yubikey-full-disk-encryption* folder and run `make`.

```
cd yubikey-full-disk-encryption
make install
```


## Prepare 2nd slot
Now it's time to prepare the second slot of your YubiKey for the [challenge response authentication](https://wiki.archlinux.org/index.php/yubikey#Challenge-Response "Setup YubiKey Challenge-Response").
Touch will be also enabled. You can also install the package [`yubikey-personalization-gui`](https://www.kryptel.com/articles/yubikey_setup.php). It allows for customization of the secret key,
creation of secret key backup and writing the same secret key to multiple YubiKeys which allows for using them interchangeably for creating
same *ykfde* passphrases.

> Securely save the 20 byte length secret **key** from the output, so you can use it to initialize another YubiKey as backup.

```
ykpersonalize -v -2 -ochal-resp -ochal-hmac -ohmac-lt64 -ochal-btn-trig -oserial-api-visible
```

The output contains the secret **key** e.g. `7fb21c407f0693ab30259664680a047f8c462ccb` to replace a faulty YubiKey.

## Configure ykfde
Open `/etc/ykfde.conf` and set `YKFDE_CHALLENGE_SLOT=2` because we want to use the second slot.
Set `YKFDE_CHALLENGE_PASSWORD_NEEDED=1` so it asks for the password (2FA). Leave other settings as is, it will be changed
later.

> Please compare it carefully with the latest version you have downloaded.

```ini
### Configuration for 'yubikey-full-disk-encryption'.
### Remove hash (#) symbol and set non-empty ("") value for chosen options to
### enable them.

### *REQUIRED* ###

# Set to non-empty value to use 'Automatic mode with stored challenge (1FA)'.
#YKFDE_CHALLENGE=""

# Use 'Manual mode with secret challenge (2FA)'.
YKFDE_CHALLENGE_PASSWORD_NEEDED="1"

# YubiKey slot configured for 'HMAC-SHA1 Challenge-Response' mode.
# Possible values are "1" or "2". Defaults to "2".
YKFDE_CHALLENGE_SLOT="2"

### OPTIONAL ###

# UUID of device to unlock with 'cryptsetup'.
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_DISK_UUID=""

# LUKS encrypted volume name after unlocking.
# Leave empty to use 'cryptdevice' boot parameter.
#YKFDE_LUKS_NAME=""

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

## Encrypt 4th partition
Next step is to format the 4th partition. You can modify the arguments if you know what you are doing.

> Ensure that you use the 4th partition, replace `[device 4th partition]` with the 4th partition of your device e.g. `nvme0n1p4`

The command `ykfde-format` will prompt to enter your challenge (2FA) password. Use a strong password which you can remember.
You have to type this password every time to get access via YubiKey and to decrypt your disk. The command `ykfde-open`
will unlock a LUKS encrypted volume on a running system.

```
ykfde-format --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 /dev/[device 4th partition]
ykfde-open -d /dev/[device 4th partition] -n cryptlvm
```

Display the crypt volume with `ls -la /dev/mapper/`. Next step is to prepare the logical volumes.
