#!/bin/sh

xrdb -merge $HOME/.Xresources
#xsri --scale-height=90 --center-x --center-y --keep-aspect --color=0 ~/pic/giraffe.jpg

for f in /usr/share/fonts/*
do
    echo "adding fontdir '$f'"
    xset +fp "$f"
done
xset fp rehash

xset dpms 0 0 0
xset s 3600

xset r rate 200 40

if [ -z "$WM" ]; then
    dbus-launch ssh-agent xmonad
else
    $WM
fi
