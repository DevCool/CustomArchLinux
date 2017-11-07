#!/bin/sh
################################################
# Script is for Arch Linux created by 5n4k3
################################################
# Create a new user account if it's not there
# already.
################################################

echo -n "Enter a username: "
read input

useradd -m -p "" -g users -G adm,wheel,log,rfkill,network,audio,video,optical,floppy,storage,scanner,power -s /bin/bash "$input"
if [ "$?" = "0" ]; then
	echo "New user created!"
	passwd "$input"
	if [ ! -x /etc/sudoers.d/g_wheel ]; then
		mkdir -p /etc/sudoers.d
		echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/g_wheel
	fi
	userdel -r -f liveuser
fi
unset input
