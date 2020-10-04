#!/bin/bash

set -e

echo Installing Apache and mod-security
sudo apt-get -y install apache2 libapache2-mod-security2

echo Configuring mod-security in audit mode only
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
#sudo sed -i -r 's/^SecRuleEngine .*/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
sudo sed -i -r 's/^SecStatusEngine .*/SecStatusEngine Off/' /etc/modsecurity/modsecurity.conf

echo Installing php
sudo apt-get -y install libapache2-mod-php7.3 php7.3 php7.3-cli php7.3-common php7.3-curl php7.3-gd php7.3-imagick php7.3-imap php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-recode php7.3-soap php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-zip
sudo apt-get -y install python-certbot-apache

echo Configuring php for Apache
sudo sed -i -r 's/^max_execution_time .*/max_execution_time = 180/' /etc/php/7.3/apache2/php.ini
sudo sed -i -r 's/^max_input_time .*/max_input_time = 180/' /etc/php/7.3/apache2/php.ini
sudo sed -i -r 's/^memory_limit .*/memory_limit = 256M/' /etc/php/7.3/apache2/php.ini
sudo sed -i -r 's/^post_max_size .*/post_max_size = 20M/' /etc/php/7.3/apache2/php.ini
sudo sed -i -r 's/^upload_max_filesize .*/upload_max_filesize = 20M/' /etc/php/7.3/apache2/php.ini

sudo a2enmod http2
sudo a2enmod headers
sudo a2enmod rewrite

echo Installing default https site
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
sudo a2ensite 000-default-ssl.conf

echo Restarting Apache
sudo systemctl restart apache2

echo ================================ SUCCESS ================================
