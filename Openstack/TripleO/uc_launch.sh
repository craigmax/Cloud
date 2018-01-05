#!/bin/bash
echo "Beginning UnderCloud setup..."
echo 
echo "*************************************"
sleep 5

clear
sudo cd ~

./uc_prewarm.sh

cd ~

./uc_config.sh

echo "Contents of Undercloud config file >>"

grep -v '^[#]\|^\s*$' ./undercloud.conf |more

echo 

read -p "Is the config file correct? Y/N: "

if ! [[ "$REPLY" = "Y" || "$REPLY" = "y" ]]; then
 exit
fi

echo

read -p "Begin Undercloud instalation now? Y/N: "

if ! [[ "$REPLY" = "Y" || "$REPLY" = "y" ]]; then
 exit
fi

openstack undercloud install




