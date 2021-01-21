Hit tab to unselect buttons and scroll through the text using UP/DOWN or
PGUP/PGDN. All announcements are stored in `/opt/openhabian/docs/CHANGELOG.md`
for you to lookup.

## openHABian 1.9 released based on Debian 12 bookworm ## March 13, 2024
We stepped up to latest Debian Linux release. The openHABian image for RPis
uses Raspberry Pi OS (lite) and we finally managed to switch over to latest
RaspiOS which is "bookworm" based.
Note that not all 3rd party tools are fully tested with bookworm homegear.
If you run a bullseye (Debian 11) or even older distribution, please read the
docs how to reinstall. It's safer to reinstall (and import your old config,
of course) than to attempt doing a dist-upgrade.
See also the OH4 migration FAQ on the forum.

## Raspberry Pi 5 support ## March 13, 2024
Support for the new Raspberry Pi 5 is also included as part of the bookworm update.
Please note that while a RPi5 has new HW features such as PCI-E SSD, nothing has
changed about peripheral support in openHABian, unsupported parts may work or not.

<<<<<<< HEAD
=======
## Future of master branch ## January 20, 2021
We will no longer make regular updates to the master branch as we migrate away from supporting openHAB2.
As such in the coming months we will make bug fixes directly to the 'stable' branch for openHA2.
With that said, please migrate off of the 'master' branch as it will be deleted soon.
You can change branches at any time use menu option 01.


## openHAB 3 released ## December 21, 2020
In the darkest of times (midwinter for most of us), openHAB 3 gets released.
See [documentation](docs/openhabian.md#on-openhab3) and [www.openhab.org](http://www.openhab.org) for details.

Merry Christmas and a healthy New Year !


## WiFi Hotspot ## November 14, 2020
Whenever your system has a WiFi interface that fails to initialize on installation or startup,
openHABian will now launch a [WiFi hotspot](docs/openhabian.md#WiFi-Hotspot) you can use to connect your system to an existing WiFi network.


## Tailscale VPN network ## October 6, 2020
Tailscale is a management toolset to establish a WireGuard based VPN between multiple systems
if you want to connect to openHAB(ian) instances outside your LAN over Internet.
It'll take care to detect and open ports when you and your peers are located behind firewalls.
This makes use of the tailscale service. Don't worry, for private use it's free of charge.
>>>>>>> e0c020454 (Update NEWS.md)
