#!/bin/sh

xrdb -load ~/.Xresources

xrandr --auto

sxhkd &
picom &
polybar &
~/.fehbg


exec bspwm

