#!/bin/sh
# Downloads all of the suckless.org repos
###################################################

reponames=("blind" "dmenu" "dwm" "ii" "lchat" "sent" "sites" "slock" "slstatus" "st" "surf" "wmname" "xssstate")

echo -n "Do you want to download all of suckless.org's repos (Y/N)? "
read input

if [[ "$input" = "y" || "$input" = "Y" ]]; then
	echo "Downloading repos..."
	for repo in ${reponames[@]}; do
		echo "Downloading repo : git://git.suckless.org/$repo"
		echo "==================================================="
		git clone git://git.suckless.org/$repo
		echo "==================================================="
		sleep 3
		unset repo
	done
	echo "Done fetching repositories!"
else
	echo "Not fetching repositories..."
fi
unset input

echo -n "Do you want to download my dwm patch (Y/N)? "
read input

if [[ "$input" = "y" || "$input" = "Y" ]]; then
	echo "Downloading dwm-config.patch!"
	wget -O dwm-config.patch "https://www.dropbox.com/s/wlpeg22wgpcw2ze/dwm-config.patch?dl=1" || echo "Error: Could not download dwm-config.patch!"
	echo -ne "\n\n"
	echo "============================"
	echo "=    Download complete     ="
	echo "============================"
	if [ -d dwm ]; then
		patch -p 0 < "dwm-config.patch"
		echo "Patch successfully applied!"
	fi
else
	echo "Not downloading patch!"
fi

echo -n "Do you want to install all suckless.org's repos (Y/N)? "
read input

if [[ "$input" = "y" || "$input" = "Y" ]]; then
	workdir=$(pwd)
	echo "Installing software..."
	for repo in ${reponames[@]}; do
		echo "Installing repo : $repo"
		echo "==================================================="
		cd $workdir/$repo
		make && sudo make install
		echo "==================================================="
		echo "Done with installing : $repo"
		echo "==================================================="
		sleep 2
		unset repo
	done
	echo "Done install all repos!"
else
	echo "Not installing any repositories..."
fi
unset input
