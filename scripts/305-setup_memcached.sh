#!/usr/bin/env bash
echo "******************************"
echo "* 305-setup_memcached.sh     *"
echo "******************************"

# Enable trace printing and exit on the first error
set -ex

# Setup Memcached
if [ ! -f /etc/memcached.conf ]; then
    apt-get install -y memcached 2>&1

    sed -i 's/-m 64/-m 1024/' /etc/memcached.conf
    echo -e "\n# Disable UDP to limit scope for DOS attacks:\n-U 0" >> /etc/memcached.conf

    systemctl restart memcached
fi
