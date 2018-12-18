# Enable YubiKey Login

Alright, you have already setup full disk encryption with YubiKey but what good is this if anyone can log in without YubiKey?
This chapter describes how to use the YubiKey for authentication inclusive *sudo*.

> Have you already created a new user? Don't use *root* user here.

## Challenge response authentication setup
You can read more about that in [Local Authentication Using Challenge Response](https://developers.yubico.com/yubico-pam/Authentication_Using_Challenge-Response.html).
Let's install the needed package *yubico-pam*:

```
sudo pacman -S yubico-pam
```

Next step is to set the current user to require the YubiKey for logon with the following commands:

```
mkdir $HOME/.yubico
ykpamcfg -2 -v
```

It is generally a good idea to move the challenge file in a system-wide path that is only read- and writable by root.

> It is important that the file is named with the name of the user that is going to be authenticated by this YubiKey.

```
sudo mkdir /var/yubico
sudo chown root.root /var/yubico
sudo chmod 700 /var/yubico

sudo mv ~/.yubico/challenge-123456 /var/yubico/[username]-123456
sudo chown root.root /var/yubico/[username]-123456
sudo chmod 600 /var/yubico/[username]-123456
```

## Activation
Let's active the YubiKey for logon. For this open the file with `vi /etc/pam.d/system-auth` and add the following line
after the *pam_unix.so* line.

> Please login to another tty in case of something goes wrong so you can deactivate it. Don't forget to become root.

```
auth   required        pam_yubico.so mode=challenge-response chalresp_path=/var/yubico
```

The complete file should look something like this.

```
#%PAM-1.0

auth      required  pam_unix.so     try_first_pass nullok
auth      required  pam_yubico.so   mode=challenge-response chalresp_path=/var/yubico
auth      optional  pam_permit.so
auth      required  pam_env.so

account   required  pam_unix.so
account   optional  pam_permit.so
account   required  pam_time.so

password  required  pam_unix.so     try_first_pass nullok sha512 shadow
password  optional  pam_permit.so

session   required  pam_limits.so
session   required  pam_unix.so
session   optional  pam_permit.so
```

## Test it
Arch Linux loads the [PAM](https://wiki.archlinux.org/index.php/PAM "Linux Pluggable Authentication Modules (PAM) ") config files on every login. So simply switch to
another tty and try to login. After you have entered your password, the YubiKey should flash and you have to touch the
YubiKey button. Good luck!

**Congratulations**! You have hopefully successful finished the YubiKey Full Disk Encryption Guide. You have reached the
following goals which is really awesome!

- YubiKey encrypted `root (/)` and `home (/home)` folder on separated partitions
- Encrypted `/boot` partition
- UEFI Secure boot (self signed boot loader)
- YubiKey authentication for user login

If you have any suggestions don't hesitate to [create an issue](https://github.com/sandrokeil/yubikey-full-disk-encryption-secure-boot-uefi/issues "Create a new issue") to improve this guide.
Also spread the word about this guide so more people can secure their system.

You should now check the *security* chapter to improve security further.