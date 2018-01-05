#!/bin/bash

# Read/Set $AdminIP
LOCALIP=$(sed -n "s/^IPADDR=//p" /etc/sysconfig/network-scripts/ifcfg-Admin)

read -p "Please, enter the CIDR block for the Admin/PXE network eg. 192.168.24.0/24: " NETCIDR

# Prompt/Set Prov DHCP Start
read -p "Please, enter the DHCP Start address for the Provisioning range: " PROVDHCPSTART

# Prompt/Set Prov DHCP End
read -p "Please, enter the DHCP End address for the Provisioning range: " PROVDHCPEND

# Prompt/Set Insp DHCP Start
read -p "Please, enter the DHCP Start address for the Inspection range: " INSPDHCPSTART

# Prompt/Set Insp DHCP End
read -p "Please, enter the DHCP Start address for the Inspection range: " INSPDHCPEND

# Update conf file 

sed -i "s/localhost/$HOSTNAME/g" ~/undercloud.conf

sed -i "s/localip/$LOCALIP/g" ~/undercloud.conf

sed -i "s:netcidr:$NETCIDR:g" ~/undercloud.conf


sed -i "s/provdhcpstart/$PROVDHCPSTART/g" ~/undercloud.conf

sed -i "s/provdhcpend/$PROVDHCPEND/g" ~/undercloud.conf


sed -i "s/inspdhcpstart/$INSPDHCPSTART/g" ~/undercloud.conf

sed -i "s/inspdhcpend/$INSPDHCPEND/g" ~/undercloud.conf




