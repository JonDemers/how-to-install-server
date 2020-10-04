# How To Install Server

This repo contains scripts to automate server installation of **WooCommerce on Debian**.

## Quickstart

For the impatient, on your local workstation:

```
git clone https://github.com/JonDemers/how-to-install-server.git
./how-to-install-server/start-remote-install.sh
```

## More details

The scripts should work on Ubuntu as well, although this was not tested. Minor adjustments may be needed.

Run the script `./start-remote-install.sh` on your local workstation to start remote server installation. Or run the scripts `./on-linux/*` on server itself.

The result is a WooCommerce LAMP server:

- Swap space of 1GB (mostly unused)
- Outbound emails using msmtp-mta
- System auto-update (nightly)
- Apache, MariaDB & PHP
- ModSecurity (audit mode)
- Wordpress (unlimited sites supported)
- Let's Encrypt certificate for HTTPS (certbot)
- Concise instructions to configure WooCommerce

WooCommerce configuration is the last step and must be done manually inside WordPress administration interface. Omitting this last step will result in a vanilla WordPress install.

Pre-requisites:

- Debian-based VM (tested on Debian 10 AWS Nano instance 512MB ram + 8GB SSD)
- Domain name with DNS pointing to the VM.
- Email provider with SMTP (tested with Namecheap Private Email)

## WooCommerce unlimited sites

To configure more WooCommerce (or wordpress) sites, just rerun the script `./on-linux./03-install-wordpress-woocommerce.sh` on the server.
