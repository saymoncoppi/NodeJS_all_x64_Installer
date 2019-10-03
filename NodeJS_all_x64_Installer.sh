#!/usr/bin/env bash
#
# NodeJS_all_x64_Installer.sh
# https://github.com/nodejs/help/wiki/Installation
# About: A bash script to automate the install or update NodeJS on any Linux x64 distributions.
# Source : https://github.com/saymoncoppi/NodeJS_all_x64_Installer
# Created: 30/09/2019
# -------------------------------------------------------------------------
clear; echo #clear screen and clean line
IWhite='\e[0;97m'
Color_Off='\e[0m'
echo -e "\e[0;97mNodeJS all x64 Installer\e[0m"
ROOT_UID=0

# check command avalibility
function has_command() {
    command -v $1 > /dev/null
}

	if [ "$UID" -eq "$ROOT_UID" ]; then
	# TODO
	# Checking pre installed version
	# NODEJS_VERSION_PRE_INSTALLED=$(node -v)
	# test $NODEJS_VERSION_PRE_INSTALLED && echo "$NODEJS_VERSION_PRE_INSTALLED is already installed!" || echo "Lets do this!"
	# echo "Update the NodeJS? (Y/N)"; read $UPDATE_NODEJS


		# architecture
		MACHINE_TYPE=`uname -m`
			if [ ${MACHINE_TYPE} == 'x86_64' ]; then
			DISTRO=linux-x64
			else
			echo "Ops... Not supported architecture on this script"
			fi

		# NodeJS version from https://raw.githubusercontent.com/nodejs/Release/master/schedule.json
		NODEJS_CODENAME_FILE="https://raw.githubusercontent.com/nodejs/Release/master/schedule.json"

		# Check connection
		wget --quiet --tries=1 --spider "${NODEJS_CODENAME_FILE}"
		if [ $? -eq 0 ]; then
			echo "Checking the latest..."
		else
			echo "Ops! No Internet Connection!"
			exit
		fi

		# extracting versions
		NODEJS_LATEST_LTS_CODENAME=$(wget -qO- "${NODEJS_CODENAME_FILE}" | grep "codename" | cut -f 2 -d ":" | sed 's/"//g' | awk 'NF > 0' | tail -1 | tr -d ' ')
		NODEJS_LATEST_LTS_URL=$(echo "https://nodejs.org/download/release/latest-$NODEJS_LATEST_LTS_CODENAME/" | awk '{print tolower($0)}')

		NODEJS_VERSION_PREP=$(wget -nv -q -O- "${NODEJS_LATEST_LTS_URL}" | grep -o 'node-v*.*.*-linux-x64.tar.xz')
		NODEJS_VERSION_FILE_NAME=$(echo $NODEJS_VERSION_PREP | cut -f 2 -d ">")
		NODEJS_VERSION=$(echo $NODEJS_VERSION_FILE_NAME | sed -n -e 's/^.*node-v//p' | sed 's/\-linux-x64.tar.xz//g')
		NODEJS_FULL_LINK=$NODEJS_LATEST_LTS_URL$NODEJS_VERSION_FILE_NAME # fix this versions
		
		#echo "Checking the latest..."
		[[ ! -z "$NODEJS_VERSION" ]] && echo "Founded NodeJS v$NODEJS_VERSION." || echo "Any version found! Check your Internet connection."

		# Set Output dir 
		NODEJS_LINUX_X64_INSTALL_DIR="${NODEJS_LINUX_X64_INSTALL_DIR:-/usr/local/lib/nodejs}"
		NODEJS_LINUX_X64_INSTALL_DIR_BKP="/usr/local/lib/nodejs_BKP"
		# re-create it.
		if [ -d "$NODEJS_LINUX_X64_INSTALL_DIR" ]; then
				#making backup before installation
			cp -r "$NODEJS_LINUX_X64_INSTALL_DIR" "$NODEJS_LINUX_X64_INSTALL_DIR_BKP"
			NODEJS_LINUX_X64_INSTALL_DIR_BKP_SIZE=$(du -c "$NODEJS_LINUX_X64_INSTALL_DIR_BKP" | cut -f 1 | tail -1)
			rm -rf "$NODEJS_LINUX_X64_INSTALL_DIR"
			mkdir -p "$NODEJS_LINUX_X64_INSTALL_DIR"
		else
			mkdir -p "$NODEJS_LINUX_X64_INSTALL_DIR"
		fi

		# Stop on any error
		set -eu

		# Make and switch to the staging directory
		cd $NODEJS_LINUX_X64_INSTALL_DIR


		# Now get the latest LTS NodeJS package for the users architecture
		echo ""
		echo "Downloading and Uncompressing:"
		wget -q --show-progress "$NODEJS_FULL_LINK"
		sudo tar -xJf node-v$NODEJS_VERSION-$DISTRO.tar.xz
		NODEJS_LINUX_X64_INSTALL_DIR_SIZE=$(du -c "$NODEJS_LINUX_X64_INSTALL_DIR/node-v$NODEJS_VERSION-$DISTRO" | cut -f 1 | tail -1)
		NODEJS_VERSION_FILE_SIZE=$(du -k "$NODEJS_LINUX_X64_INSTALL_DIR/$NODEJS_VERSION_FILE_NAME" | cut -f1)


		# Exporting PATH
		PATH_NODEJS="$NODEJS_LINUX_X64_INSTALL_DIR/node-v$NODEJS_VERSION-$DISTRO"
		export PATH=$PATH_NODEJS:$PATH

		# Making Shorcuts
		echo ""
		echo "Updating symlinks:"
		for NODEJS_COMPONENT in node npm npx
		do
			test -f /usr/bin/$NODEJS_COMPONENT && rm -rf /usr/bin/$NODEJS_COMPONENT
			echo "Updated $NODEJS_COMPONENT symlink."
			ln -s $PATH_NODEJS/bin/$NODEJS_COMPONENT /usr/bin/$NODEJS_COMPONENT
		done
		
		# Cleaning things
		cd ~
		echo ""
		echo "Cleanup unnecessary files:"
		if [ -d "$NODEJS_LINUX_X64_INSTALL_DIR_BKP" ]; then
			rm -rf "$NODEJS_LINUX_X64_INSTALL_DIR_BKP"
			echo "Cleaning $NODEJS_LINUX_X64_INSTALL_DIR_BKP_SIZE kb from backups"
		fi
		echo "Cleaning $NODEJS_VERSION_FILE_SIZE kb from $NODEJS_VERSION_FILE_NAME"
		rm -rf $NODEJS_LINUX_X64_INSTALL_DIR/$NODEJS_VERSION_FILE_NAME

		# cleanup NPM
		# https://gist.github.com/brock/5b1b70590e1171c4ab54
		# https://askubuntu.com/questions/1036806/how-to-remove-npm-and-reinstall-npm-completely-in-18-04
		# https://github.com/tj/node-prune

# Tell the user we are done
NODEJS_VERSION_INSTALLED=$(node -v)
echo ""
echo "NodeJS $NODEJS_VERSION_INSTALLED installed!"
echo ""

# done

# refreshing profile
#source ~/.profile && echo "File .bash_profile reloaded correctly" || echo "Syntax error, could not import the file"
    else
		# Message  
		echo -e "Ops! Please run this script as root..."
	fi