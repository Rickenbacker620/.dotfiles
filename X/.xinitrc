#!/bin/sh

xrdb -load ~/.Xresources

xrandr --auto

sxhkd &
picom &

exec bspwm

