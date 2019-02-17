#!/usr/bin/env bash
echo "******************************"
echo "* 306-setup_ntp.sh           *"
echo "******************************"

# Enable trace printing and exit on the first error
set -ex

# Setup Ntp
if [ ! -f /etc/ntp.conf ]; then
    apt-get install -y ntp 2>&1
fi
