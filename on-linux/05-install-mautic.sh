#!/bin/bash

set -e

cd $(dirname "$0")

source $(dirname "$0")/../server-config.sh

VHOST=$(echo $MAUTIC_VHOST_PATH|sed -r 's/\/.*//')
db_user=$(echo $MAUTIC_VHOST_PATH|sed -r 's/[^a-z0-9]+/_/g')

echo MAUTIC_VHOST_PATH=$MAUTIC_VHOST_PATH
echo ADMIN_EMAIL=$ADMIN_EMAIL
echo VHOST=$VHOST
echo db_user=$db_user

echo Creating DB user $db_user
bash -c 'openssl rand -hex 12 > /root/'$db_user'_pass.txt'
db_pass=$(cat /root/${db_user}_pass.txt)
mysql --user=root <<EOF
  DROP DATABASE IF EXISTS $db_user;
  DROP USER IF EXISTS '$db_user'@'localhost';
  CREATE DATABASE $db_user;
  grant all privileges on $db_user.* to '$db_user'@'localhost' identified by '$db_pass';
  FLUSH PRIVILEGES;
EOF

MAUTIC_INSTALL_DIR=/var/www/$MAUTIC_VHOST_PATH
echo Downloading and installing Mautic to $MAUTIC_INSTALL_DIR
MAUTIC_VERSION=3.3.3
rm -rf mautic-$MAUTIC_VERSION.zip
wget https://github.com/mautic/mautic/releases/download/$MAUTIC_VERSION/$MAUTIC_VERSION.zip -O mautic-$MAUTIC_VERSION.zip
# rm -rf $MAUTIC_INSTALL_DIR
mkdir -p $MAUTIC_INSTALL_DIR
cd $MAUTIC_INSTALL_DIR
unzip $(dirname "$0")/mautic-$MAUTIC_VERSION.zip
chown -R www-data:www-data .
find . -type d -not -perm 755 -exec chmod 755 {} +
find . -type f -not -perm 644 -exec chmod 644 {} +
chmod -R g+w var/cache/ var/logs/ app/config/
chmod -R g+w media/files/ media/images/ translations/

APACHE_CONFIG_FILE=/etc/apache2/sites-available/$VHOST.conf
if [ ! -f "$APACHE_CONFIG_FILE" ]; then

  echo Configuring apache VirtualHost $VHOST in $APACHE_CONFIG_FILE
  bash -c 'cat > '$APACHE_CONFIG_FILE' <<EOF
<VirtualHost *:80>
  ServerName '$VHOST'
  ServerAdmin '$ADMIN_EMAIL'

  Protocols h2 h2c http/1.1

  DocumentRoot /var/www/'$VHOST'
  <Directory /var/www/'$VHOST'>
    Options +FollowSymlinks
    AllowOverride All
    Require all granted
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/'$VHOST'-error.log
  CustomLog \${APACHE_LOG_DIR}/'$VHOST'-access.log combined
</VirtualHost>
EOF'

  a2ensite $VHOST.conf
  systemctl restart apache2

  echo Installing certificate for $VHOST
  certbot -n --apache --agree-tos --redirect --uir --hsts --staple-ocsp --must-staple -d $VHOST -m $ADMIN_EMAIL

fi

echo "

================================ SUCCESS ================================

To complete the installation, follow docs at https://docs.mautic.org/en/setup/getting-started#pre-flight-checks

Your installation: https://$MAUTIC_VHOST_PATH/
  Database Host: localhost
  Database Port: 3306
  Database Name: $db_user
  Database Table Prefix: <empty> (leave default value)
  Database Username: $db_user
  Database Password: $db_pass

On next screens, use this email:
  Your Email: $SMTP_FROM

Go to https://$MAUTIC_VHOST_PATH/s/config/edit
  Go to System Settings
    Update CORS Settings

Go to https://$MAUTIC_VHOST_PATH/s/config/edit
  Go to Email Settings
    Under Mail Send Settings, Send test email
    Under Message Settings, configure Default email signature

Go to https://$MAUTIC_VHOST_PATH/s/users/edit/1
  Set Timezone (you may need to logout/login for it to take effect)
"
