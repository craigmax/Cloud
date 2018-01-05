#!/bin/bash -e

echo "============================================"
echo "Joomla Install Script"
echo "============================================"
dbname='{{server.database_name}}'
dbuser='{{server.database_username}}'
dbpass='{{server.database_password}}'

echo "Creating database with the name '$dbname'..."
mysql -u root --password="${dbpass}" <<-EOSQL
  CREATE DATABASE $dbname;
  CREATE USER ${dbuser}@localhost;
  SET PASSWORD FOR ${dbuser}@localhost= PASSWORD("${dbpass}");
  GRANT ALL PRIVILEGES ON $dbname.* TO ${dbuser}@localhost IDENTIFIED BY '${dbpass}';
  FLUSH PRIVILEGES;
EOSQL


function getLatestVersion
{
    CODE="import json,sys;
release=json.load(sys.stdin);
if 'assets' in release:
    for asset in release['assets']:
        if 'Full_Package' in asset['browser_download_url']:
            print asset['browser_download_url']
            break
";
    JoomlaURL=$(curl -ks "https://api.github.com/repos/joomla/joomla-cms/releases/latest" | python -c "$CODE");
}

getLatestVersion
echo $JoomlaURL

# make Joomla home
mkdir -p /var/www/html/joomla
cd /var/www/html/joomla

# download Joomla
wget $JoomlaURL -O Joomla.tar.bz2

# unzip Joomla
tar -xjf Joomla.tar.bz2

#set ownership
chown apache: -R /var/www/html/joomla

echo "

<VirtualHost localhost:80>
 ServerName Joomla
 DocumentRoot "/var/www/html/joomla"
 DirectoryIndex index.php
 Options FollowSymLinks
 ErrorLog logs/joomla-error_log
 CustomLog logs/joomla-access_log common
</VirtualHost>

#Redirect root site to Joomla
RedirectMatch ^/$ /joomla/

" >> /etc/httpd/conf/httpd.conf

#restart apache
service httpd restart

#cleanup
rm ./Joomla.tar.bz2
cd ~

echo "========================="
echo "Installation is complete."
echo "========================="