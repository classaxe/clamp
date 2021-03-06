#!/usr/bin/env bash
echo "******************************"
echo "* 100-setup_apache.sh        *"
echo "******************************"

# Enable trace printing and exit on the first error
set -ex

# Setup Apache
apt-get install -y apache2 2>&1
a2dismod mpm_prefork mpm_worker
a2enmod rewrite actions ssl headers
a2enmod proxy_fcgi
a2enmod proxy_http
a2enmod proxy_balancer

if [ "${install_varnish}" = "y" ]; then
    # Change Listen Port
    sed -i 's/Listen 80$/Listen 8090/' /etc/apache2/ports.conf
fi

# Change user and groups to vagrant
sed -i 's/www-data$/vagrant/' /etc/apache2/envvars
if [ -f /etc/apache2/sites-available/default-ssl.conf ]; then
    rm /etc/apache2/sites-available/default-ssl.conf
fi

# Setup VHOST Script
yes | cp -rf /vagrant/files/vhost.sh /usr/local/bin/vhost
chmod +x /usr/local/bin/vhost

