#!/bin/sh

xrdb -load ~/.Xresources

sxhkd &
picom &
polybar &
~/.fehbg

exec bspwm
