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

		# NodeJS version
		# https://raw.githubusercontent.com/nodejs/Release/master/schedule.json
		NODEJS_LATEST_LTS_CODENAME=$(wget -qO- https://raw.githubusercontent.com/nodejs/Release/master/schedule.json | grep "codename" | cut -f 2 -d ":" | sed 's/"//g' | awk 'NF > 0' | tail -1 | tr -d ' ')
		NODEJS_LATEST_LTS_URL=$(echo "https://nodejs.org/download/release/latest-$NODEJS_LATEST_LTS_CODENAME/" | awk '{print tolower($0)}')


		NODEJS_VERSION_PREP=$(wget -nv -O- "${NODEJS_LATEST_LTS_URL}" | grep -o 'node-v*.*.*-linux-x64.tar.xz')
		NODEJS_VERSION_FILE_NAME=$(echo $NODEJS_VERSION_PREP | cut -f 2 -d ">")
		NODEJS_VERSION=$(echo $NODEJS_VERSION_FILE_NAME | sed -n -e 's/^.*node-v//p' | sed 's/\-linux-x64.tar.xz//g')
		echo $NODEJS_VERSION
		NODEJS_FULL_LINK=$NODEJS_LATEST_LTS_URL$NODEJS_VERSION_FILE_NAME # fix this versions


		# Set Output dir 
		NODEJS_LINUX_X64_INSTALL_DIR="${NODEJS_LINUX_X64_INSTALL_DIR:-/usr/local/lib/nodejs}"

		# Set temp dir
		TMP="${TMP:-/tmp}"

		# Set staging dir
		STAGINGDIR="$TMP/NODEJS_LINUX_X64_STAGING"

		# If the staging directory is already present from the past, clear it down and
		# re-create it.
		if [ -d "$STAGINGDIR" ]; then
		rm -fr "$STAGINGDIR"
		fi

		# Stop on any error
		set -eu

		# Make and switch to the staging directory
		mkdir -p "$STAGINGDIR"
		cd "$STAGINGDIR"

		# Now get the latest LTS NodeJS package for the users architecture
		#wget "https://nodejs.org/download/release/latest-v10.x/node-$NODEJS_VERSION-$DISTRO.tar.xz"
		wget "$NODEJS_FULL_LINK"

		# Extract the contents package
		echo "Uncompressing $NODEJS_VERSION_FILE_NAME..."
		sudo tar -xJf node-v$NODEJS_VERSION-$DISTRO.tar.xz -C $NODEJS_LINUX_X64_INSTALL_DIR

		# Exporting PATH
		PATH_NODEJS="$NODEJS_LINUX_X64_INSTALL_DIR/node-v$NODEJS_VERSION-$DISTRO"
		export PATH=$PATH_NODEJS:$PATH

		# Making Shorcuts
		echo ""
		for NODEJS_COMPONENT in node npm npx
		do
			test -f /usr/bin/$NODEJS_COMPONENT && rm -rf /usr/bin/$NODEJS_COMPONENT
			echo "Updating $NODEJS_COMPONENT symlink."
			ln -s $PATH_NODEJS/bin/$NODEJS_COMPONENT /usr/bin/$NODEJS_COMPONENT
		done
		
		# Removing staging directory
		cd "$NODEJS_LINUX_X64_INSTALL_DIR"
		rm -rf "$STAGINGDIR"

# Tell the user we are done
echo ""
NODEJS_VERSION_INSTALLED=$(node -v)
echo $NODEJS_VERSION_INSTALLED
echo "NodeJS $NODEJS_VERSION installed!"

# refreshing profile
#source ~/.profile && echo "File .bash_profile reloaded correctly" || echo "Syntax error, could not import the file"
    else
		# Message  
		echo -e "Ops! Please run this script as root..."
	fi