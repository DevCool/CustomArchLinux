#!/bin/sh
########################################
# Simple installer script I made, by
# Philip '5n4k3' Simonson
########################################

echo -n "Do you want to auto partition (Y/N)? "
read answer
if [[ "$answer" = "y" || "$answer" = "Y" ]]; then
	echo -n "Enter your device: "
	read input
	if [ "$input" = "" ]; then
		echo "You need to enter a device."
		exit 1
	else
		unset answer
		echo -n "Would you like to wipe your drive (Y/N)? "
		read answer
		if [[ "$answer" = "y" || "$answer" = "Y" ]]; then
			wipe -Ifre $input
			unset answer
		else
			echo "Not wiping drive: $input"
			unset answer
		fi
		echo -n "Would you like an encrypted LVM (Y/N)? "
		read answer
		if [[ "$answer" = "y" || "$answer" = "Y" ]]; then
			parted -s $input mklabel gpt
			parted -s $input mkpart primary 1MiB 32MiB
			parted -s $input mkpart primary ext2 32MiB 1GiB
			parted -s $input mkpart primary 1GiB 100%
			parted -s $input set 1 bios_grub on
			parted -s $input set 2 boot on
			parted -s $input set 3 lvm on
			if [ "$?" = "0" ]; then
				# create the luks volumes
				cryptsetup luksFormat -c aes-xts-plain64:sha512 -h sha512 -s 512 "$input"3
				cryptsetup luksOpen "$input"3 vault0
				pvcreate /dev/mapper/vault0
				vgcreate system /dev/mapper/vault0
				lvcreate -C y -L +9G -n swap system       #edit size if needed
				lvcreate -C n -l 100%FREE -n root system  #edit size if needed
				# format and mount
				mkfs.ext2 "$input"2
				mkfs.ext4 /dev/system/root
				mkswap /dev/system/swap
				swapon /dev/system/swap
				mount /dev/system/root /mnt
				mkdir -p /mnt/boot
				mount "$input"2 /mnt/boot
			else
				echo "Could not partition the drive properly."
			fi
		else
			parted -s $input mklabel gpt
			parted -s $input mkpart primary 1MiB 32MiB
			parted -s $input mkpart primary ext2 32MiB 1GiB
			parted -s $input mkpart primary linux-swap 1GiB 9GiB
			parted -s $input mkpart primary ext4 9GiB 100%
			parted -s $input set 1 bios_grub on
			parted -s $input set 2 boot on
			if [ "$?" = "0" ]; then
				# format and mount
				mkfs.ext2 "$input"2
				mkswap "$input"3
				swapon "$input"3
				mkfs.ext4 "$input"4
				mount "$input"4 /mnt
				mkdir /mnt/boot
				mount "$input"2 /mnt/boot
			else
				echo "Could not partition the drive properly."
			fi
		fi
		parted -s $input print
	fi
	unset input
fi

echo -n "Do you wish to continue installing (Y/N)? "
read input

if [[ "$input" = "y" || "$input" = "Y" ]]; then
	rsync -aAXvP /* /mnt --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/.gvfs}
	cp -avT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz /mnt/boot/vmlinuz-linux
	sed -i 's/Storage=volatile/#Storage=auto/' /mnt/etc/systemd/journald.conf

	rm /mnt/etc/udev/rules.d/81-dhcpcd.rules
	rm /mnt/root/{.automated_script.sh,.zlogin}
	rm -r /mnt/etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
	rm /mnt/etc/systemd/scripts/choose-mirror
	rm /mnt/etc/sudoers.d/g_wheel
	rm /mnt/etc/mkinitcpio-archiso.conf
	rm -r /mnt/etc/initcpio

	sed -i '9 s/^/#/' /mnt/etc/skel/.bash_profile
	genfstab -L /mnt >> /mnt/etc/fstab && cat /mnt/etc/fstab
	arch-chroot /mnt /bin/bash
	rm /mnt/usr/bin/{dl_repos,install,setup-user}.sh
	umount /mnt -R
	unset input
else
	echo "You chose not to install my custom arch!"
fi
