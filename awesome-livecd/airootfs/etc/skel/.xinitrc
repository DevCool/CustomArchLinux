#!/bin/sh

#
# ~/.xinitrc
#

if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi


#########################################################
# awesomewm -   Awesome Window Manager
#########################################################
exec awesome


#########################################################
# dwm       -   Dynamic Window Manager
#########################################################

# set the window date
#while true; do
#	xsetroot -name "$( date +"%F %R" )"
#	sleep 1m
#done &
# set autolock on
#xautolock -locker "xlock -enablesaver -font fixed -mode matrix" -nowlocker "xlock -enablesaver -font fixed -mode matrix" &
#feh --bg-scale ~/.config/awesome/themes/wallpapers/greenskull1.jpg &

#exec dwm
