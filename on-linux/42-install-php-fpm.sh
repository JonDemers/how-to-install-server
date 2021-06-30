#!/bin/bash

set -e

cd $(dirname "$0")

# echo '<?php phpinfo(); ?>' > /var/www/html/info.php
# curl -k https://localhost/info.php > ~/info.php.mpm_prefork.html

/etc/init.d/apache2 stop

a2dismod php7.3
a2dismod mpm_prefork
a2enmod mpm_event

apt-get -y install php7.3-fpm
apt-get -y install libapache2-mod-fcgid

a2enconf php7.3-fpm
a2enmod proxy
a2enmod proxy_fcgi

echo Configuring php-fpm for Apache
sed -i -r 's/^max_execution_time .*/max_execution_time = 180/' /etc/php/7.3/fpm/php.ini
sed -i -r 's/^max_input_time .*/max_input_time = 180/' /etc/php/7.3/fpm/php.ini
sed -i -r 's/^memory_limit .*/memory_limit = 256M/' /etc/php/7.3/fpm/php.ini
sed -i -r 's/^post_max_size .*/post_max_size = 20M/' /etc/php/7.3/fpm/php.ini
sed -i -r 's/^upload_max_filesize .*/upload_max_filesize = 20M/' /etc/php/7.3/fpm/php.ini

# cat /etc/apache2/conf-enabled/php7.3-fpm.conf

reboot

# curl -k https://localhost/info.php > ~/info.php.mpm_event.html
# rm -rf /var/www/html/info.php
