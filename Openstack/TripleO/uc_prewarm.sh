#!/bin/bash

sudo sed -i "s/localhost/$HOSTNAME/g" /etc/hosts

sudo yum clean all
sudo yum repolist

sudo yum install -y yum-utils
sudo yum-config-manager --enable rhelosp-rhel-7-server-opt

sudo curl -L -o /etc/yum.repos.d/delorean-mitaka.repo https://trunk.rdoproject.org/centos7-mitaka/current/delorean.repo

sudo curl -L -o /etc/yum.repos.d/delorean-deps-mitaka.repo https://trunk.rdoproject.org/centos7-mitaka/delorean-deps.repo

sudo yum -y install --enablerepo=extras centos-release-ceph-hammer
sudo sed -i -e 's%gpgcheck=.*%gpgcheck=0%' /etc/yum.repos.d/CentOS-Ceph-Hammer.repo

sudo curl -L -o /etc/yum.repos.d/delorean.repo https://trunk.rdoproject.org/centos7-master/current-passed-ci/delorean.repo

sudo curl -L -o /etc/yum.repos.d/delorean-current.repo https://trunk.rdoproject.org/centos7/current/delorean.repo
sudo sed -i 's/\[delorean\]/\[delorean-current\]/' /etc/yum.repos.d/delorean-current.repo
sudo /bin/bash -c "cat <<EOF>>/etc/yum.repos.d/delorean-current.repo includepkgs=diskimage-builder,instack,instack-undercloud,os-apply-config,os-collect-config,os-net-config,os-refresh-config,python-tripleoclient,openstack-tripleo-common,openstack-tripleo-heat-templates,openstack-tripleo-image-elements,openstack-tripleo,openstack-tripleo-puppet-elements,openstack-puppet-modules,openstack-tripleo-ui,puppet-* EOF"

sudo curl -L -o /etc/yum.repos.d/delorean-deps.repo https://trunk.rdoproject.org/centos7/delorean-deps.repo

sudo yum -y install --enablerepo=extras centos-release-ceph-jewel
sudo sed -i -e 's%gpgcheck=.*%gpgcheck=0%' /etc/yum.repos.d/CentOS-Ceph-Jewel.repo

sudo yum -y install yum-plugin-priorities

sudo yum install -y python-tripleoclient

cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf
