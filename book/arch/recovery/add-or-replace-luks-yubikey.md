# Add or Replace LUKS YubiKey

> Create a reliable backup of your files!

This chapter describes how to add a new YubiKey or replace an YubiKey for an already encrypted LUKS volume.

You need these things:
- Your current (old) YubiKey
- Your new Yubikey
- Make sure YubiKey login is disabled

> This is only needed if you don't have the secret key of your current YubiKey
and if you want to replace it with another YubiKey or to add a second different YubiKey.
See *Replace a faulty YubiKey* if you want to initialize a new YubiKey with the secret key.

> If you are changing the passphrase of your new YubiKey, don't forget to update the *YKFDE_CHALLENGE* in `/etc/ykfde.conf`

Prepare your new YubiKey like described in chapter *03: Prepare 2nd slot* if not already done.

Display current used LUKS key slots with `cryptsetup luksDump /dev/[device 4th partition]`.

## Disable YubiKey login

If you use YubiKey login, disable it and reread chapter *07: Enable YubiKey Login* after this procedure.
To disable YubiKey login open the file `/etc/pam.d/system-auth` and comment out the line:

```
auth   required        pam_yubico.so mode=challenge-response chalresp_path=/var/yubico
```

Use another tty to test it.

## Add an YubiKey to LUKS

Execute `ykfde-enroll -d /dev/[device 4th partition] -s [keyslot_number] -o`. The option `-o` uses the old YubiKey
for the passphrase. Ensure your new YubiKey is inserted, you will be asked to insert the old YubiKey.

## Killing a LUKS key slot

> Ensure you are not killing a wrong key slot and make sure another key slot is working.

To test which YubiKey belongs to which key slot execute `ykfde-open -d /dev/[device 4th partition] -s [keyslot_number] -t`.

Execute `ykfde-enroll -d /dev/[device 4th partition] -s [keyslot_number] -k`.  The option `-k` kills the slot.

## Replacing existing LUKS key slot

> It is recommended to add a new YubiKey to another slot and kill the other slot if all things work.

Execute `ykfde-enroll -d /dev/[device 4th partition] -s [keyslot_number] -o -c `. The option `-c` changes the key slot.