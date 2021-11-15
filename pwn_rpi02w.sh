#!/bin/bash

model=$(grep -i "zero 2" /proc/cpuinfo )
if [ -n "${model}" ]
then
    echo "This script should be run on a non- Zero model 2 system"
    echo "bailing out..."
    exit 1
fi

echo "This should fix pwnagotchi on you RPI Zero 2 w."
sleep 1

if [ ! \( \( "${USER}" = "root" \) -o \( -n "${EUID}" -a ${EUID} = 0 \) \) ]
then
	echo "This script is designed to be run as root, or run with sudo."
        exit 1
fi

echo "If you are not running as root you have 5 seconds to stop this and run as root. If you are running as root just wait 5 seconds."
sleep 5

# stop running services
systemctl stop pwnagotchi bettercap pwngrid-peer.service

# work around dependency issues during the upgrade process
apt-mark hold kalipi-bootloader kalipi-kernel
apt --allow-releaseinfo-change update && apt full-upgrade -y
apt-mark unhold kalipi-bootloader kalipi-kernel

apt install -y libraspberrypi0=5.4.83-20210516 libraspberrypi-bin=5.4.83-20210516 libraspberrypi-dev=5.4.83-20210516
apt-mark hold libraspberrypi0 libraspberrypi-bin libraspberrypi-dev

apt full-upgrade -y

apt-mark unhold firmware-brcm80211
apt install -y firmware-brcm80211
 
pip3 install --upgrade numpy

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
