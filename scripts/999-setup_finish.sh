#!/usr/bin/env bash
echo "******************************"
echo "* 999-setup_finish.sh        *"
echo "******************************"

# Restart Services
service apache2 restart
if [ "${install_varnish}" = "y" ]; then
    service varnish restart
fi
for f in /etc/profile.d/*-aliases.sh; do source $f; done
phpRestart
