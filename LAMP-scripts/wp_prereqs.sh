#!/bin/sh

python -mplatform | grep -qi ubuntu
is_ubuntu=$?

if [ $is_ubuntu -eq 0 ]; then
    apt-get install -y apache2 php libapache2-mod-php php-mysql php-mysqlnd curl debconf-utils
else
    yum install -y httpd php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt 
fi