#!/bin/bash

sudo /etc/init.d/dhcpcd restart
sudo wpa_supplicant -B -Dwext -iwlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf
