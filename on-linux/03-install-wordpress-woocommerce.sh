#!/bin/bash

set -e

cd $(dirname "$0")

source $(dirname "$0")/../server-config.sh

VHOST=$(echo $VHOST_PATH|sed -r 's/\/.*//')
db_user=$(echo $VHOST_PATH|sed -r 's/[^a-z0-9]+/_/g')

echo VHOST_PATH=$VHOST_PATH
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

WP_INSTALL_DIR=/var/www/$VHOST_PATH
echo Downloading and installing Wordpress to $WP_INSTALL_DIR
rm -rf wordpress-5.5.1.tar.gz
wget https://wordpress.org/wordpress-5.5.1.tar.gz
rm -rf wordpress
tar xvfz wordpress-5.5.1.tar.gz
# rm -rf $WP_INSTALL_DIR
mkdir -p $WP_INSTALL_DIR
cp -r wordpress/* $WP_INSTALL_DIR
cd $WP_INSTALL_DIR
chown -R www-data:www-data .

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

echo ================================ SUCCESS ================================
echo
echo "To complete the installation, visit http://$VHOST_PATH/wp-admin/install.php"
echo "Database Name: $db_user"
echo "Username: $db_user"
echo "Password: $db_pass"
echo "Database Host: localhost"
echo "Table Prefix: wp_ (or leave default value)"
echo
echo "On next screen, make sure you use the following email address when creating a user, this will be used as 'From' when sendign emails. Misconfiguring this will cause issues with emails."
echo "Your Email: $SMTP_FROM"
echo
echo "Configure site settings:"
echo "In Settings / General, review and configure the site and save" 
echo "In Settings / Permalinks, select 'Post name' and save" 
echo
echo "Install theme and plugins:"
echo "Install and Activate theme Astra: http://$VHOST_PATH/wp-admin/theme-install.php?search=astra"
echo "Install and Activate and Configure plugin: WooCommerce http://$VHOST_PATH/wp-admin/plugin-install.php?s=WooCommerce&tab=search&type=term"
echo "Install and Activate plugin: Starter Templates (By Brainstorm Force): http://$VHOST_PATH/wp-admin/plugin-install.php?s=Starter+Templates&tab=search&type=term"
echo
echo "Cleanup demo data:"
echo "Delete all Posts, Media, Pages, Comments"
echo "In Appareance, delete all Menus, Header Footer & Blocks, etc"
echo
echo "Import site:"
echo "In Appearance / Starter Templates, select Elementor" 
echo "Consider eCommerce templates Organic Store (food) or Brandstore or Simply Natural or Custom Printing (fasion)"
echo "Click on Import Complete Site, check Delete previously imported site, and import"
echo
echo "Configure Woocommerce settings:"
echo "In WooCommerce / Settings / Accounts & Privacy. Check only:"
echo " - Allow customers to place orders without an account"
echo " - Allow customers to log into an existing account during checkout"
echo " - Allow customers to create an account during checkout"
echo " - Allow customers to create an account on the \"My account\" page"
echo "On same page, uncheck this:"
echo " - When creating an account, automatically generate an account password"
echo
echo "Setup stripe:"
echo "In WooCommerce / Home, click 'Set up payments', select Stripe so that it installs Stripe option"
echo "In WooCommerce / Settings / Payments, locate Stripe and set it up with test API key/secret"
echo " - Test mode"
echo " - Test Secret Key"
echo " - Test Secret Key"
echo "In Stripe (https://dashboard.stripe.com/account/webhooks), setup webhook provided in WooCommerce page, click 'receive all events'"
echo
echo "Create a test order on the site (use a different browser or logout from wordpress admin):"
echo "Reboot the VM to make sure everything works correctly after reboots"
echo "Check to see Customer from test order is there (could take some time before appearing...)"
