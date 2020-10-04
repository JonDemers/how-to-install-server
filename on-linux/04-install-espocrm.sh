#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
	echo "Usage: $(basename "$0") <SERVER_HOSTNAME> <ADMIN_EMAIL>"
	exit 1
fi

SERVER_HOSTNAME=$1
ADMIN_EMAIL=$2

echo SERVER_HOSTNAME=$SERVER_HOSTNAME
echo ADMIN_EMAIL=$ADMIN_EMAIL

bash -c 'openssl rand -hex 12 > /root/mysql_espocrm_pass.txt'
mysql_espocrm_pass=$(cat /root/mysql_espocrm_pass.txt)
mysql --user=root <<EOF
  CREATE DATABASE espocrm;
  grant all privileges on espocrm.* to 'espocrm'@'localhost' identified by '$mysql_espocrm_pass';
  FLUSH PRIVILEGES;
EOF

wget https://www.espocrm.com/downloads/EspoCRM-5.9.3.zip
unzip EspoCRM-5.9.3.zip
cp -r EspoCRM-5.9.3 /var/www/$SERVER_HOSTNAME
cd /var/www/$SERVER_HOSTNAME
find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +
find data custom client/custom -type d -exec chmod 775 {} +
find data custom client/custom -type f -exec chmod 664 {} +
chmod 775 application/Espo/Modules client/modules
chown -R www-data:www-data .

bash -c 'cat > /etc/apache2/sites-available/'$SERVER_HOSTNAME'.conf <<EOF
<VirtualHost *:80>
  ServerName '$SERVER_HOSTNAME'
  ServerAdmin '$ADMIN_EMAIL'

  Protocols h2 h2c http/1.1

  DocumentRoot /var/www/'$SERVER_HOSTNAME'
  <Directory /var/www/'$SERVER_HOSTNAME'>
    Options +FollowSymlinks
    AllowOverride All
    Require all granted
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/'$SERVER_HOSTNAME'-error.log
  CustomLog \${APACHE_LOG_DIR}/'$SERVER_HOSTNAME'-access.log combined
</VirtualHost>
EOF'

a2ensite $SERVER_HOSTNAME.conf
systemctl restart apache2

echo '* * * * * cd /var/www/'$SERVER_HOSTNAME'; /usr/bin/php -f cron.php > /dev/null 2>&1' | crontab -u www-data -

certbot -n --apache --agree-tos --redirect --uir --hsts --staple-ocsp --must-staple -d $SERVER_HOSTNAME -m $ADMIN_EMAIL

echo ================================ SUCCESS ================================
echo Cron jobs for www-data:
crontab -u www-data -l
echo
echo Domain: $SERVER_HOSTNAME
echo Admin email: $ADMIN_EMAIL
echo DB host: localhost
echo DB user: espocrm
echo DB pass: $mysql_espocrm_pass
echo =============================== REBOOTING ===============================
