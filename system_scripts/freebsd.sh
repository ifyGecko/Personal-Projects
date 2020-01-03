#!/bin/sh

pkg install -y xorg

pkg install -y stumpwm

echo "startx /usr/share/bin/stumpwm" > .xinitrc

echo "XTerm*background:BLACK" > .Xdefaults
echo "XTerm*foreground:RED" >> .Xdefaults

pkg install -y emacs-nox

pkg install -y firefox
