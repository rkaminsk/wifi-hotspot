# Creating a hotspot

This repository contains a script and the necessary configuration files to
start a wifi hotspot. In theory the hotspot could be set up via the
networkmanager alone but for some reason it did not work for all devices. It
worked fine for an Android phone but not for an iPad. There is quite some
information about configuring hotspots on the internet but not so much about
how to play nice with the networkmanager and firewalld services. So the script to
start the hotspot here uses the `nmcli` and `firewalld` commands to set up the
hotspot.

To create a hotspot, the `hostapd` and `dnsmasq` packages have to be installed.
The configuration of both daemons in `/etc/hostapd/hostapd.conf`,
`/etc/dnsmasq.conf`, and `/etc/hosts.dnsmasq` has to be adjusted as in the
configuration files in this repository. It is *important* to replace all
occurrences of `<hostname>`, `<password>`, `<in-device>`, and `<out-device>` in
*all* files with proper values. The field `<hostname>` should be replaced with
the hostname of the machine. The fields `<hostname>` and `<password>` will be
used as ssid and password when connecting to the hotspot. The field
`<in-device>` should be set to the device that provides the hotspot and the
field `<out-device>` should be set to the device connected to the internet.
Then, to start the hotspot, only the `hotspot.sh` script has to be executed as
root user.

For example, to get the required values, run the following:

```bash
$ hostname
meabau

$ nmcli device show | grep GENERAL.DEVICE -A1
GENERAL.DEVICE:                         enp0s31f6
GENERAL.TYPE:                           ethernet
--
GENERAL.DEVICE:                         wlp1s0
GENERAL.TYPE:                           wifi
```

Here `<hostname>` is `meabau`, `<in-device>` is `wlp1s0` and `<out-device>` is
`enp0s31f6`.
