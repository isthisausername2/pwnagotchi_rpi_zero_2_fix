#!/bin/bash

echo "This should fix pwnagotchi on you RPI Zero 2 w."
sleep 1

if [ ! \( \( "${USER}" = "root" \) -o \( -n "${EUID}" -a ${EUID} = 0 \) \) ]
then
	echo "This script is designed to be run as root, or run with sudo."
        exit 1
fi

echo "If you are not running as root you have 5 seconds to stop this and run as root. If you are running as root just wait 5 seconds."
sleep 5

if [ ! -e /etc/apt/preferences.d/kali.pref ];
then
	cat <<EOF >/etc/apt/preferences.d/kali.pref
Package: *
Pin: release n=kali-pi
Pin-Priority: 999
EOF

	# this sets the correct priority for upgrades so we don't have to be so hacky!
fi

# stop running services
systemctl stop pwnagotchi bettercap pwngrid-peer.service

# work around release-info changes during the upgrade process
apt --allow-releaseinfo-change update

# Unhold, and upgrade these packages only from the kali-pi repo
# apt install -y -t kali-pi libraspberrypi0 libraspberrypi-bin libraspberrypi-dev kalipi-bootloader kalipi-kernel

# Packages get installed here, prefering kali-pi for all packages they provide; debian for all others
apt full-upgrade -y

# piZero-v2 doesn't support monitor mode https://github.com/seemoo-lab/nexmon/issues/500

pip3 install --upgrade numpy

# This is temporary, and gets us a working wifi driver, though without promiscuous monitor mode initially
# We just want the 43436 driver; unless it already exists, and then future updates should handle it
if [ ! -e /lib/firmware/brcm/brcmfmac43436-sdio.bin ]
then
	mkdir /lib/firmware/brcm/old
	cp /lib/firmware/brcm/* /lib/firmware/brcm/old
	apt install -y firmware-brcm80211
	cp /lib/firmware/brcm/old/* /lib/firmware/brcm/
fi

echo "Reboot required to fully apply changes"

# Comands and reserch on fixing this done by github user skontrolle. I just put the comands in as script.
# GitHub link to orignal issue https://github.com/evilsocket/pwnagotchi/issues/1046
# Orignal messange from skontrolle
# additional changes by ak_hepcat


# I just retraced all of my steps with a clean 1.5.5 image to make sure I didn't have any issues with my backup config.

# raw image doesn't boot on zero2
# boot 0w
# sudo apt update && sudo apt full-upgrade -y
# swap card to zero2
# boots but no wifi for bettercap
# install firmware not upgraded in the full-upgrade sudo apt install firmware-brcm80211; reboot
# pwnagotchi starts, mon0 interface up & can iwlist mon0 scan, numpy error in logs, all epochs are blind
# update numpy sudo pip3 install --upgrade numpy to resolve [BUG] pwnagotchi numpy error  #1015
# with numpy fixed, all epochs are still blind, and the AI fails in import cv2
# sudo apt install libavcodec58 libavformat58; these remove the kalipi-bootloader. reboot for good measure
# epochs still blind, AI starts really quickly, pwnagotchi restarts after 50 blind epochs.
# drop card back in 0w, everything works.
