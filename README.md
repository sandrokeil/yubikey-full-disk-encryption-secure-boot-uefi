# YubiKey Full Disk Encryption

[This repository](https://github.com/sandrokeil/yubikey-full-disk-encryption-secure-boot-uefi "YubiKey Full Disk Encryption Repository") 
contains a step-by-step tutorial to create a full disk encryption setup with two factor authentication (2FA) 
via [YubiKey](https://yubico.com/products/yubikey-hardware/). It contains:

- YubiKey encrypted `root (/)` and `home (/home)` folder on separated partitions
- Encrypted `/boot` partition
- UEFI Secure boot (self signed boot loader)
- YubiKey authentication for user login

Currently guides for:

- Arch Linux 

## Why
It took me several days to figure out how to set up a fully encrypted machine with 2FA. This guide should help
others to get it done in minutes (hopefully). There exists a plenty bunch of tutorials but no one contains a step-by-step 
guide to get the above things done.

> I guess the entire manual will take between 1 - 3 hours.

## Prerequisites
You should be familiar with linux and should be able to edit files with `vi` [Vi Cheat Sheet](http://www.lagmonster.org/docs/vi.html).
You need an USB stick for the Linux Live environment and a second computer would be useful for look ups and to read this guide while
preparing your fully encrypted Linux.

And of cource you will need an [YubiKey](https://www.yubico.com/products/yubikey-hardware/ "Discover YubiKeys").

## Documentation

For the latest online documentation visit [http://sandrokeil.github.io/yubikey-full-disk-encryption-secure-boot-uefi/](http://sandrokeil.github.io/yubikey-full-disk-encryption-secure-boot-uefi/ "Latest yubikey-full-disk-encryption-secure-boot-uefi documentation").
Refer the *Quick Start* section for a detailed explanation. 

Documentation is [in the book tree](book/), and can be compiled using [bookdown](http://bookdown.io) or [Docker](https://www.docker.com/)

```console
$ docker run -it --rm -v $(pwd):/app sandrokeil/bookdown bookdown.json
$ docker run -it --rm -p 8080:8080 -v $(pwd):/app php:7.1-cli php -S 0.0.0.0:8080 -t /app/html
```

or run *bookdown*

```console
$ ./vendor/bin/bookdown bookdown.json
$ php -S 0.0.0.0:8080 -t html/
```

Then browse to [http://localhost:8080/](http://localhost:8080/)
