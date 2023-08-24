#!/bin/sh

xrdb -load ~/.Xresources

xrandr --auto

exec bspwm

