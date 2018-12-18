# Disable INTEL AMT
This page describes how to disable INTEL Active Management Technology. Please read the whole page before you begin.
The INTEL AMT is a [security risk](https://thehackernews.com/2018/01/intel-amt-vulnerability.html "INTEL AMT vulnerabilities").

> Don't forget to set a secure BIOS supervisor password!

## Open INTEL AMT
To open INTEL AMT press *CTRL + P* on boot. The default password is *admin* and
you should change it to a secure one. You will be ask to change the password
on the first login.

## Disable Intel Management Engine State Control
Next step is to [Disable Intel Management Engine State Control](https://www.dell.com/support/article/de/de/debsdt1/sln295179/disable-intel-amt-intel-management-engine-state-control?lang=en).

1. Choose *Intel ME General Settings* from menu
1. Choose *Intel ME State Control* from menu
1. Choose *Disable*
1. Choose *Previous* from menu

The machine will reboot now. You can still access INTEL AMT but if you
enable it again it should use your password and not the default one.

## Disable INTEL AMT in BIOS
> **Attention:** Depending on the used INTEL AMT version you **can not**
disable the Intel Management Engine State Control because then the password will be reset. If you don't
see any entry to disable INTEL AMT, check if you have installed the latest BIOS version.

Boot into BIOS and search for the *Intel AMT* entry and enter it.
For Lenovo notebooks it's under the menu *Config*. Choose *Disable* and save BIOS settings.

## Validate password protection
Now it's time to check, if the password is reset if you enable it again. Go into BIOS and enable
INTEL AMT, save changes and open INTEL AMT with *CTRL + P*. Enable it again, the machine will reboot.
Go into INTEL AMT with *CTRL + P* and now you should not be able to login with password *admin*.
Now start from scratch and disable it again.