As an **openHAB end user** looking for a system to run on, please check out the official documentation:
-   <https://www.openhab.org/docs/installation/openhabian.html>

# openHABian - Hassle-free openHAB Setup
[![GitHub](https://img.shields.io/github/license/openhab/openhabian)](https://github.com/openhab/openhabian/blob/main/LICENSE.md)
[![ShellCheck](https://github.com/openhab/openhabian/actions/workflows/shellcheck-action.yml/badge.svg)](https://github.com/openhab/openhabian/actions/workflows/shellcheck-action.yml)
[![BATS](https://github.com/openhab/openhabian/actions/workflows/bats-action.yml/badge.svg)](https://github.com/openhab/openhabian/actions/workflows/bats-action.yml)
[![Installation](https://github.com/openhab/openhabian/actions/workflows/installation-action.yml/badge.svg)](https://github.com/openhab/openhabian/actions/workflows/installation-action.yml)
[![Build](https://github.com/openhab/openhabian/actions/workflows/build-action.yml/badge.svg)](https://github.com/openhab/openhabian/actions/workflows/build-action.yml)

<img align="right" width="220" src="./docs/images/logo.svg" />

openHABian is here to provide a **self-configuring** Linux system setup to meet the needs of every openHAB user, in two flavors:

*   A **SD-card image pre-configured with openHAB** for all *Raspberry Pi* models
*   As a set of scripts that sets up openHAB and tools on any Debian based system

### A note on dedication and commitment
openHABian is for starters *and* expert users. We sometimes read about people deciding against use of openHABian because they want to install additional software and believe openHABian does not let them do this.
Everybody wants their home automation to be stable and most people install a dedicated RPi, i.e. they don't install any other software there that may interfere with proper openHAB operation.
Reasonably so, this is our clear recommendation. Saving another 100 bucks is not worth putting the reliable day-to-day operations of your home at risk.

Then again that being said, those who want to can use openHABian as the starting point for their 'generic' server and run whatever software else on top.
There's no genuine reason why this wouldn't work. The openHABian image is really just Raspberry Pi OS (lite) under the hood and openHABian is "just" some scripts that install a number of packages and configure the system in a specific way, optimized to run openHAB.


## On openHAB 4 and older
openHABian will install **openHAB 5** and Java 21 by default.
To have it install openHAB 4 or openHAB 3 right from the beginning, set `clonebranch=openHAB4` or `clonebranch=openHAB3`, respectively, in `openhabian.conf` before first boot. Use `clonebranch=legacy` to get openHAB 2.

## Hardware
### Hardware recommendation
Let's put this first: our current recommendation is to get a RPi model 4 or 5 with 2 or 4 GB of RAM, whatever you can get hold of for a good price, plus an "
Endurance" SD card. If you want to be on the safe side, order the official 3A power supply, else any old mobile charger will usually do. Cards named "Endurance" can handle more write cycles and will be more enduring under openHAB\'s use conditions.
Prepare to make use of the [SD mirroring feature](openhabian.md#SD-mirroring), get a 2nd SD card right away, same model or at least the size of your internal one, plus a USB card reader.

### Hardware support
As of openHABian version 1.6 and later, all Raspberry Pi models are supported as hardware.
openHABian can run on x86 based systems but on those you need to install the OS yourself.
Anything else ARM based such as ODroids, OrangePis and the like may work or not.
NAS servers such as QNAP and Synology boxes will not work.

We strongly recommend Raspberry Pi 4 or 5 systems that have 2 GB of RAM or more.
RPi 2/3 only have 1 GB of RAM and RPi 1 and 0/0W just have a single CPU core and only 512 MB of RAM. The RPi0W2 has 4 cores but only 512 MB as well.
512 MB can be sufficient to run a smallish openHAB setup, but it will not be enough to run a full-blown system with many bindings and memory consuming openHABian features/components such as zram or InfluxDB.
We do not actively prohibit installation on any hardware, including unsupported systems, but we might skip or deny to install specific extensions such as those memory hungry applications named above.

Supporting hardware means testing every single patch and every release.
There are simply too many combinations of SBCs, peripherals and OS flavors that maintainers do not have available, or, even if they did, the time to spend on
the testing efforts that is required to make openHABian a reliable system.
It means that to run on hardware other than RPi 2/3/4/5 or bare metal x86 Debian may work but is not a supported setup.
Please stay with a supported version. This will help you and those you will want to ask for help on the forum focus on a known set of issues and solutions.

For ARM hardware that we don't support, you can try any of the [fake hardware parameters](openhabian.md#fake-hardware-mode) to 'simulate' RPi hardware and Ra
spberry Pi OS.


### OS support
Going beyond what the RPi image provides, as a manually installed set of scripts, we support running openHABian on x86 hardware on generic Debian.
We provide code that is reported "as-is" to run on Ubuntu but we do not support Ubuntu so please don't open issues for this (PRs then again are welcome).
Several optional components such as WireGuard or Homegear are known to expose problems on Ubuntu.

Note with openHAB 4 and Java 17, `buster` and older distros are no longer supported and there'll be issues when you attempt upgrading Java 11->17.
Note openHAB 5 and Java 21 require a 64 bit image.
Should you still be running an older distribution, we recommend not to upgrade the distro but to re-install using the latest openHABian image and import your
config instead.
