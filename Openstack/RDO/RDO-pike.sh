#!/bin/bash

yum update -y
yum install -y yum-utils 
yum install -y centos-release-openstack-pike

yum-config-manager --enable openstack-pike
yum update -y

yum install -y openstack-packstack

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

#packstack --allinone
#packstack --answer-file=./RDO-answers.txt
