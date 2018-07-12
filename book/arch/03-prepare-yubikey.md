# Prepare YubiKey

Download or mount [yubikey-full-disk-encryption](https://github.com/agherzan/yubikey-full-disk-encryption) and install it
in your Arch Linux Live environment. This is needed because we will format the 4rd partition with YubiKey.

Open the yubikey-full-disk-encryption folder and run `make`.

```
cd yubikey-full-disk-encryption
make install
```

Now it's time prepare the second slot of our YubiKey for the challenge response authentication. Touch will be also enabled.

```
ykpersonalize -v -2 -ochal-resp -ochal-hmac -ohmac-lt64 -ochal-btn-trig -oserial-api-visible
```

Open `/etc/ykfde.conf` and set `YKFDE_CHALLENGE_SLOT=2` because we want to use the second slot. 
Set `YKFDE_CHALLENGE_PASSWORD_NEEDED=1` so it asks for the password (2FA). Feel free to modify it tou your needs 
e.g. enable TRIM (but be warned, there are potential security implications) support.

> Please compare it carefully with the latest version you have downloaded.

```ini
# Configuration for yubikey-full-disk-encryption. ("") means an empty value.

### *REQUIRED* ###

# Set to non-empty value to use 'Automatic mode with stored challenge (1FA)'.
#YKFDE_CHALLENGE=""

# Use 'Manual mode with secret challenge (2FA)'.
YKFDE_CHALLENGE_PASSWORD_NEEDED="1"

# Choose YubiKey slot configured for 'HMAC-SHA1 Challenge-Response' mode. Possible values are "1" or "2".
YKFDE_CHALLENGE_SLOT="2"

### OPTIONAL ###

# Set partition UUID. Leave empty to use 'cryptdevice' kernel parameter.
#YKFDE_DISK_UUID=""

# Set LUKS encrypted volume name. Leave empty to use 'cryptdevice' kernel parameter.
#YKFDE_LUKS_NAME=""

# If left empty this will be set as "/dev/disk/by-uuid/$YKFDE_DISK_UUID" -- device to unlock with 'cryptsetup luksOpen'.
#YKFDE_LUKS_DEV=""

# Optional flags passed to 'cryptsetup luksOpen'. Example: "--allow-discards" for TRIM support. Leave empty to use cryptdevice kernel parameter.
#YKFDE_LUKS_OPTIONS=""

# Number of times to assemble passphrase and run 'cryptsetup luksOpen'. Defaults to "5".
#YKFDE_CRYPTSETUP_TRIALS="5"

# Number of seconds to wait for inserting YubiKey, "-1" means 'unlimited'. Defaults to "30".
#YKFDE_CHALLENGE_YUBIKEY_INSERT_TIMEOUT="30"

# Number of seconds passed to 'sleep' after succesful decryption. Defaults to empty, meaning NO sleep.
#YKFDE_SLEEP_AFTER_SUCCESSFUL_CRYPTSETUP=""

# Enable verbose output. It will print all secrets to terminal. Use only for debugging.
#DBG="1"
```

Next step is to format the 4rd partition. You can modify the arguments if you know what you are doing. 
Ensure that you use the 4rd partition e.g. `nvme0n1p4`

```
ykfde-format --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 5000 --type luks2 /dev/[device 4rd partition]
ykfde-open -d /dev/[device 4rd partition] -n cryptlvm
```

Display the crypt volume with `ls /dev/mapper`. Next step is to [preparing the logical volumes](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_logical_volumes "preparing the logical volumes")
for `/` and `/home` directory.

```
mount /dev/MyVolGroup/root /mnt
mkdir /mnt/home
mount /dev/MyVolGroup/home /mnt/home
```
