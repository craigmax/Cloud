#!/bin/sh

# Original script taken from https://gist.github.com/bgallagh3r/2853221 and modified

echo "============================================"
echo "WordPress Install Script"
echo "============================================"
dbname='{{server.database_name}}'
dbuser='{{server.database_username}}'
dbpass='{{server.database_password}}'
dbhost='{{blueprint_context.db.server.ip}}'

echo "Creating database with the name '$dbname'..."
mysql -u root --password="${dbpass}" <<-EOSQL
  CREATE DATABASE $dbname;
  CREATE USER ${dbuser}@localhost;
  SET PASSWORD FOR ${dbuser}@localhost= PASSWORD("${dbpass}");
  GRANT ALL PRIVILEGES ON $dbname.* TO ${dbuser}@localhost IDENTIFIED BY '${dbpass}';
  FLUSH PRIVILEGES;
EOSQL

# download wordpress
curl -O https://wordpress.org/latest.tar.gz
# unzip wordpress
tar -zxf latest.tar.gz
# change dir to wordpress
cd wordpress

# Open Firewall web ports
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php
perl -pi -e "s/localhost/$dbhost/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir -p wp-content/uploads
chmod 775 wp-content/uploads

echo "Copying WordPress files to /var/www/html..."
cp -r ~/wordpress/* /var/www/html


#!/bin/sh

python -mplatform | grep -qi ubuntu
is_ubuntu=$?

if [ $is_ubuntu -eq 0 ]; then
    mv /var/www/html/index.html /var/www/html/index.old
    chown -R www-data:www-data /var/www/html/
    chmod -R 755 /var/www/html/
    systemctl restart apache2.service 
    systemctl restart mysql.service 
else
    chown -R apache /var/www/html/wp-content/uploads
    service httpd restart
fi

echo "Cleaning..."
rm ../latest.tar.gz

echo "========================="
echo "Installation is complete."
echo "========================="