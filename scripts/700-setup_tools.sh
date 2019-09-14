#!/usr/bin/env bash
echo "******************************"
echo "* 700-setup_tools.sh         *"
echo "******************************"

# Enable trace printing and exit on the first error
set -ex

# Setup Composer
if [ ! -f /usr/local/bin/composer ]; then
    cd /tmp
    php=/opt/phpfarm/inst/php-$(ls -1 /opt/phpfarm/inst/ | grep php | head -n1 | cut -d'-' -f2)/bin/php;
    curl -sS https://getcomposer.org/installer | ${php}
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    apt install zip unzip php7.0-zip
fi

# Setup Node, NPM and Grunt
if [ ! -f /usr/bin/npm ]; then
    apt-get install -y python-software-properties
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt-get install -y nodejs
    npm install -g grunt
fi 

# Setup n98 for M1, M2 and automatic selection based on platform in use
if [ ! -f /usr/local/bin/n98 ] || [ ! -f /usr/local/bin/n98-1 ] || [ ! -f /usr/local/bin/n98-2 ]; then
    cd /tmp
    rm -f n98-magerun*

    wget --progress=bar:force https://files.magerun.net/n98-magerun.phar
    mv n98-magerun.phar /usr/local/bin/n98-1
    chmod +x /usr/local/bin/n98-1

    wget --progress=bar:force https://files.magerun.net/n98-magerun2.phar
    mv n98-magerun2.phar /usr/local/bin/n98-2
    chmod +x /usr/local/bin/n98-2

    cp /vagrant/files/n98 /usr/local/bin/n98
    chmod +x /usr/local/bin/n98
fi

# Setup PHP Code Sniffer and Code fixer:
if [ ! -d /usr/local/bin/phpcs ]; then
    cd /usr/local/bin;
    git clone https://github.com/squizlabs/PHP_CodeSniffer.git phpcs
    git clone -b master https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git wpcs
    sudo cp /vagrant/files/CodeSniffer.conf /usr/local/bin/phpcs
fi
