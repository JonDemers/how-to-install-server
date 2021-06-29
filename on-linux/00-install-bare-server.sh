#!/bin/bash

set -e

source $(dirname "$0")/../server-config.sh

echo SERVER_HOSTNAME=$SERVER_HOSTNAME
echo ADMIN_EMAIL=$ADMIN_EMAIL
echo SMTP_HOST=$SMTP_HOST
echo SMTP_PORT=$SMTP_PORT
echo SMTP_TLS=$SMTP_TLS
echo SMTP_TLS_STARTTLS=$SMTP_TLS_STARTTLS
echo SMTP_FROM=$SMTP_FROM
echo SMTP_USER=$SMTP_USER
echo SMTP_PASS=hidden

echo Updating system
apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove

echo Configuring hostname
# Hostname should not match any VirtualHost ServerName, otherwise it will conflict with 000-default.conf
hostnamectl set-hostname $SERVER_HOSTNAME

echo Creating swap
swapoff -a
fallocate -l 1024m /swapfile
chmod 600 /swapfile
mkswap /swapfile
cp /etc/fstab /etc/fstab-$(date "+%Y.%m.%d-%H.%M.%S").bak
bash -c 'echo /swapfile swap swap defaults 0 0 >> /etc/fstab'
cp /etc/sysctl.conf /etc/sysctl.conf-$(date "+%Y.%m.%d-%H.%M.%S").bak
bash -c 'echo vm.swappiness = 1 >> /etc/sysctl.conf'

echo Configuring email
apt-get -y install msmtp-mta unzip zip
touch /var/log/msmtp
chmod 666 /var/log/msmtp

bash -c 'cat > /etc/aliases.msmtp <<EOF
default: '$ADMIN_EMAIL'
EOF'

bash -c 'cat > /etc/msmtprc <<EOF
defaults
logfile /var/log/msmtp
aliases /etc/aliases.msmtp

account mainaccount
host '$SMTP_HOST'
port '$SMTP_PORT'
tls '$SMTP_TLS'
tls_starttls '$SMTP_TLS_STARTTLS'
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on
from '$SMTP_FROM'
user '$SMTP_USER'
password '$SMTP_PASS'

account default : mainaccount
EOF'

echo Configuring nightly auto-update
bash -c 'cat > /root/dist-upgrade.sh <<EOF
#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo
echo ===========================================================
echo
echo Staring \$(date)
echo

echo Memory usage before upgrade
free -m
echo

apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove

echo Memory usage after upgrade
free -m
echo

reboot

EOF'

chmod 755 /root/dist-upgrade.sh

echo '00 10 * * * /root/dist-upgrade.sh >> /root/dist-upgrade.log 2>&1' | crontab -

dmesg

free -m

echo Cron jobs for root:
crontab -l
echo
echo Domain: $SERVER_HOSTNAME
echo ================================ SUCCESS ================================
