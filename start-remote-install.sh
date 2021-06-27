#!/bin/bash

set -e

ROOT_DIR=$(dirname "$0")
cd $ROOT_DIR

if [ ! -f "./server-config.sh" ]; then
  cat <<EOF
Please create configuration file server-config.sh
Use server-config-sample.sh as a starting point:

    cp $(dirname "$0")/server-config-sample.sh $(dirname "$0")/server-config.sh
    vi $(dirname "$0")/server-config.sh
EOF
  exit 1
fi

source ./server-config.sh

echo Copying files on server...

ssh-keygen.exe -R $SERVER_HOSTNAME

scp -i $SSH_ID_FILE -r on-linux server-config.sh $SSH_USER@$SERVER_HOSTNAME:~

time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "bash ~/on-linux/99-configure-user.sh"
time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/99-configure-user.sh"
time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/00-install-bare-server.sh"

set +e
time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo reboot"
set -e
echo
echo Waiting for server to reboot
sleep 20

time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/01-install-mariadb.sh"
time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/02-install-apache-and-php.sh"

time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/03-install-wordpress-woocommerce.sh"

#time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/04-install-espocrm.sh $ESPO_1_VHOST $ESPO_1_ADMIN_EMAIL"

#time ssh -i $SSH_ID_FILE $SSH_USER@$SERVER_HOSTNAME "sudo bash ~/on-linux/05-install-mautic.sh"
