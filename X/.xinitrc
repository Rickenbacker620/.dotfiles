#!/bin/sh

xrandr --auto

~/.fehbg &

xmodmap ~/.Xmodmap

exec bspwm

