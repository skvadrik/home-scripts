#!/bin/bash

sudo /etc/init.d/dhcpcd stop
sudo killall -9 wpa_supplicant
sudo ifconfig wlan0 down