#!/bin/bash

#For install apache 2.4.62
/usr/bin/sudo dpkg -P --force-depends libapr1:amd64 libapr1-dev libaprutil1:amd64 libaprutil1-dev
/usr/bin/sudo dpkg -P --force-depends apache2 apache2-bin apache2-data apache2-utils
/usr/bin/sudo rm -rf /usr/local/apache2 /usr/local/apr
/bin/chmod -R +x apache_2_4_62/*
/usr/bin/sudo cp -r apache_2_4_62/apache2 /usr/local/
/usr/bin/sudo cp -r apache_2_4_62/apr /usr/local/
/usr/bin/sudo cp apache_2_4_62/dhparams.pem /etc/pki/tls/certs/

#services steps moved below
/usr/bin/sudo mkdir -p /var/cache/apache2/mod_cache_disk


#For install PHP 8.3.9
/bin/chmod -R +x php_dependencies/* php8_3_packages/*

#remove php8.1 if installed
/usr/bin/sudo dpkg -P --force-depends libapache2-mod-php8.1 php8.1 php8.1-bcmath php8.1-cli php8.1-common php8.1-curl php8.1-gd php8.1-imagick php8.1-ldap php8.1-mbstring php8.1-mysql php8.1-opcache php8.1-readline php8.1-soap php8.1-xml php8.1-zip

#remove php8.3 if installed
/usr/bin/sudo dpkg -P --force-depends libapache2-mod-php8.3 php8.3 php8.3-bcmath php8.3-cli php8.3-common php8.3-curl php8.3-gd php8.3-imagick php8.3-ldap php8.3-mbstring php8.3-mysql php8.3-opcache php8.3-readline php8.3-soap php8.3-xml php8.3-zip php8.3-pgsql php8.3-sqlite3 php8.3-intl
/usr/bin/sudo rm -rf /etc/php/8.1 /etc/php/8.3

#install php packages
/usr/bin/sudo dpkg -i php_dependencies/*.deb
/usr/bin/sudo dpkg -i php8_3_packages/*.deb
/usr/bin/sudo rm /usr/lib/apache2/modules/mod_security2.so
/usr/bin/sudo dpkg -P --force-depends libapache2-mod-security2
/usr/bin/sudo cp -r php.ini /etc/php/8.3/apache2/


#services overwrite with existing apache-bin which installed with libapache2-mod-php8.3 
/usr/bin/sudo cp -r apache_2_4_62/apache2.service /lib/systemd/system/
/usr/bin/sudo ln -sf /lib/systemd/system/apache2.service /etc/systemd/system/multi-user.target.wants/apache2.service
/usr/bin/sudo cp -r apache_2_4_62/apache-htcacheclean.service /lib/systemd/system/
/usr/bin/sudo ln -sf /lib/systemd/system/apache-htcacheclean.service /etc/systemd/system/multi-user.target.wants/apache-htcacheclean.service

#remove apache2 from /usr/sbin 
/usr/bin/sudo rm /usr/sbin/apache2

/usr/bin/sudo cp ioncube_loader_lin_8.3.so /usr/lib/php/20230831/
/usr/bin/sudo chmod 644 /usr/lib/php/20230831/ioncube_loader_lin_8.3.so

/usr/bin/sudo cp 00-ioncube.ini /etc/php/8.3/apache2/conf.d/
/usr/bin/sudo cp 00-ioncube.ini /etc/php/8.3/cli/conf.d/

echo "Apache has been updated to 2.4.62"
echo "PHP has been updated to 8.3.15"
