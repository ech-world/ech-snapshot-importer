#!/bin/bash

# splash texts
echo
echo "*** Echelon Node Snapshot Importer ***"
echo "https://github.com/ech-world/ech-snapshot-importer"
echo "https://ech.world"
echo
echo This script
echo   1. downloads the latest snapshot from ech.world
echo   2. stops the node
echo   3. removes existing data from the data folder
echo   4. extracts the downloaded snapshot package to data folder
echo   5. starts the node
echo
echo "MIT-license: https://github.com/ech-world/ech-snapshot-importer/blob/main/LICENSE"
echo "It is your responsibility to make necessary backups if you still need the existing data in node's data folder"
echo "Also, always make sure you have backed up your validator keys if you have stored them to your filesystem"
echo "For example, if you enter a wrong path when asked for data folder full path, you might suffer unexpected data loss - so back up any important data!"
echo

# we need to download the snapshot somewhere before importing it, best have user input target here
echo "Enter the full path (don't use '~') you want to download to, without filename (leave empty to use current directory): "
read snappath

# check if user gave a value or left it empty
if [ -z "$snappath" ]
then
	# populate default value here (current directory), if user left empty
	snappath=$(pwd)
fi

# latest snapshot location is stored on ech.world server in a txt-file, let us get it
echo "Trying to find latest snapshot's URL..."
sourceurl=$(wget https://ech.world/latest/snapshot-url.txt -q -O -)

# check status/error codes
if [ -z "$sourceurl" ]
then
	echo "Failed to find latest snapshot's URL! Exiting..."
	exit 3
fi

# we need to split snapshots full-URL to get the filename
IFS='/'
read -a urlsplit <<< "$sourceurl"
# would be the last member of the split array
snapfilename=${urlsplit[${#urlsplit[@]} - 1]}
snapfullpath=$snappath/$snapfilename

# create the download folder path (if it doesn't exist already)
mkdir -p "$snappath"

# time to download the snapshot
echo "Downloading latest snapshot to: $snapfullpath ..."
wget "$sourceurl" -O "$snapfullpath"

# check status/error codes
if [ $? -eq 0 ]
then
	echo "Snapshot downloaded succesfully"
else
	echo "Failed to download snapshot! Exiting..."
	exit
fi

# we need the user to confirm data folder path here
echo "Enter node's data folder full path, don't use '~' (leave empty to use /home/echelon/.echelond/data):"
read targetpath

# check if user gave a value or left it empty
if [ -z "$targetpath" ]
then
	# populate default value here, if user left empty
	targetpath="/home/echelon/.echelond/data"
fi

# let's do a bit of over-confirmation to make sure user understands they about to delete some stuff
echo
echo "Last chance to exit before removing existing data folder!"
echo "If you proceed"
echo "* the node will be stopped for the time it takes to remove old data and import new data"
echo "* '$targetpath' will be removed, type uppercase DELETE to proceed:"
read confirmation

# validate input
if [ "$confirmation" = "DELETE" ]
then
	echo "Stopping node and removing existing data folder..."
else
	echo "Confirmation failed, data removal cancelled! Exiting..."
	exit 3
fi

# if node is running (is-active returns status 0), stop it here
systemctl is-active --quiet echelond && sudo systemctl stop echelond

# check if stopped (is-active should not return status 0)
systemctl is-active --quiet echelond
if [ $? -eq 0 ]
then
	echo "Failed to stop the node, data removal cancelled! Exiting..."
	exit
else
	echo "Node stopped successfully"
fi

# we remove the data folder and create a new, empty one
echo "Removing existing data folder..."

rm -rf "$targetpath"
mkdir -p "$targetpath"

# check status/error codes
if [ $? -eq 0 ]
then
	echo "Existing data folder succesfully removed"
else
	echo "Failed to remove existing data folder! Please remove data folder contents and run this script again or manually extract the downloaded snapshot to the data folder and start your node."
	exit
fi

# we extract the snapshot
echo "Importing snapshot. It takes a while, please be patient..."
tar -xf "$snapfullpath" -C "$targetpath"

# check status/error codes
if [ $? -eq 0 ]
then
	echo "Imported snapshot succesfully"
else
	echo "Failed to import snapshot! Please check errors and try again. Exiting..."
	exit
fi

# fire the node up
echo "Starting node..."
sudo systemctl start echelond

# check that node started (is-active should return 0)
systemctl is-active --quiet echelond
if [ $? -eq 0 ]
then
	echo "Node started successfully"
else
	echo "All done but failed to start node! Please check errors and try to start it manually. Exiting..."
	exit
fi

# time for closing words
echo
echo "All done! Remember to check your node's logs to make sure everything is working: sudo journalctl -u echelond -f"
echo
