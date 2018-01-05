#!/bin/sh

# Original script taken from http://stackoverflow.com/questions/34569373/install-mysql-community-server-5-7-via-bash-shell-script-in-centos-7-x64

mysqlRootPass='{{ server.database_password }}'

echo ' -> Installing mysql server (community edition)'

python -mplatform | grep -qi ubuntu
is_ubuntu=$?

if [ $is_ubuntu -eq 0 ]; then
    #stop & remove service
    echo ' -> Removing previous mysql server installation'

    service mysql stop && apt-get -y remove mysql-server  && rm -rf /var/lib/mysql && rm -rf /var/log/mysqld.log && rm -rf /etc/my.cnf
    
    #install
    export DEBIAN_FRONTEND=noninteractive
    apt-get -q -y install mysql-server

    echo ' -> Starting mysql server (first run)'
    service mysql start

    tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"

    echo " -> Setting up new mysql server root password (tmp pass = $tempRootDBPass)"
    service mysql stop
    rm -rf /var/lib/mysql/*logfile*
    service mysql start
else
    #stop & remove service
    service mysqld stop && yum remove -y mysql-server && rm -rf /var/lib/mysql && rm -rf /var/log/mysqld.log && rm -rf /etc/my.cnf
    
    #install
    yum install -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
    yum install -y mysql-community-server
    /sbin/chkconfig --levels 235 mysqld on
    
    echo ' -> Starting mysql server (first run)'
    service mysqld start
    
    tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"
    
    echo " -> Setting up new mysql server root password (tmp pass = $tempRootDBPass)"
    service mysqld stop
    rm -rf /var/lib/mysql/*logfile*
    service mysqld start
fi

firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

mysqladmin -u root --password="$tempRootDBPass" password "$mysqlRootPass"
mysql -u root --password="$mysqlRootPass" <<-EOSQL
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test; 
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; 
    DELETE FROM mysql.user where user != 'mysql.sys'; 
    CREATE USER 'root'@'%' IDENTIFIED BY '${mysqlRootPass}';
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOSQL
echo " -> MySQL server installation completed."