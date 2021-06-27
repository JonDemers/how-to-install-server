#!/bin/bash

set -e

# Sample configuration for TLD example.com

# SERVER_HOSTNAME can be anything. However it must resolve in DNS and must be DIFFERENT than Wordpress site domain, otherwise it will conflict in Apache with 000-default.conf
SERVER_HOSTNAME=one.example.com

# SSH credentials for SERVER_HOSTNAME
SSH_USER=admin
SSH_ID_FILE=/path/to/your/ssh-id.pem

# This is the technical system admin email address. System emails for root user are delivered to this email address.
ADMIN_EMAIL=your-email@gmail.com

# SMTP provider configuration. This sample is using Namecheap Private Email
SMTP_HOST=mail.privateemail.com
SMTP_PORT=465
SMTP_TLS=on
SMTP_TLS_STARTTLS=off
SMTP_FROM=info@example.com
SMTP_USER=info@example.com
SMTP_PASS=your-smtp-password

# This sample will install Wordpress on https://example.com/
VHOST_PATH=example.com

# Subdomain and subpath installation is also supported, for instance: https://subdomain.example.com/my-store
# VHOST_PATH=subdomain.example.com/my-store

# Mautic install
MAUTIC_VHOST_PATH=t.example.com

# Work in progress
#ESPO_1_VHOST=espo.example.com
