#!/bin/sh

pkg install -y xorg

pkg install -y stumpwm

touch .xinitrc
echo "startx /usr/share/bin/stumpwm" > .xinitrc

touch .Xdefaults
echo "XTerm*background:BLACK" > .Xdefaults
echo "XTerm*foreground:RED" >> .Xdefaults

pkg install -y emacs-nox
