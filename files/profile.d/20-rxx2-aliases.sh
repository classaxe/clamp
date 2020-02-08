alias rxx2='cd /srv/www/rxx'

function installRxx2 {
    echo -e "\n\e[32m***************"
    echo -e "* installRxx2 *"
    echo -e "***************\e[0m"

    SITE_DOMAIN=rxx.classaxe.com
    DB_USER=rxx
    DB_PASS=clamp_rxx_777
    DB_NAME=rxx

    if [ ! -d /srv/www/rxx ] ; then
        echo -en "  Cloning RXX2 Codebase                               "
        git clone https://github.com/classaxe/rxx_symfony.git /srv/www/rxx          > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";

        echo -e "  Executing Composer install:"
        cd /srv/www/rxx
        composer install

        echo -e "  Executing Grunt install:"
        npm install grunt --save-dev

        echo -en "  Installing GeoIP Database                           "
        sudo add-apt-repository ppa:maxmind/ppa -y
        sudo apt update
        sudo apt install geoipupdate -y
        echo -e "AccountID 186093\nLicenseKey uGGhEqEovSe36Niu\nEditionIDs GeoLite2-ASN GeoLite2-City GeoLite2-Country" | sudo tee /etc/GeoIP.conf > /dev/null
        sudo geoipupdate
        echo -e "\e[32m[OK]\e[0m";

        echo -en "  Adding Mysql DSN Connection string to .env file     "
        sed -i 's/mysql:\/\/db_user:db_password@127.0.0.1:3306\/db_name/mysql:\/\/rxx:clamp_rxx_777@localhost:3306\/rxx?charset=UTF8/' .env
        echo -e "\e[32m[OK]\e[0m";

        echo -en "  Setting admin logon values in .env file             "
        sed -i 's/###< symfony\/framework-bundle ###/ADMIN_USER=admin\nADMIN_PASS=777\n###< symfony\/framework-bundle ###/' .env
    else
        echo -e "\e[32mSite already present - to completely rebuild it execute these commands:"
        echo -e "\e[33;1m  cd /srv/www; rm -rf /srv/www/rxx\e[0m\e[32m\e[0m\n"
        echo -en "  Updating RXX Codebase                               "
        cd /srv/www/rxx
        git pull origin master > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";

        echo -e "  Executing Composer install:"
        composer install
    fi

    echo -en "  Setting up website       \e[33;1m${SITE_DOMAIN}\e[0m           "
    sudo vhost add -n ${SITE_DOMAIN} -d /srv/www/rxx/public -p 7.3 -f > /dev/null 2>&1
    sudo service apache2 restart > /dev/null 2>&1
    echo -e "\e[32m[OK]\e[0m";

    read -n1 -p "  - Import Database (Y/n)? " choice
    echo ""
    if [[ $choice =~ ^(Y|y| ) ]] || [[ -z $choice ]]; then
        echo -en "  Fetching Database file                              "
        cd       /tmp
        rm -f    rxx.sql.gz
        wget https://www.classaxe.com/dx/ndb/rxx.sql.gz> /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";
        cd /srv/www/rxx
        echo -en "  Setting up Database                                 "
        echo "DROP SCHEMA IF EXISTS ${DB_NAME};" | MYSQL_PWD=root mysql -uroot
        echo "CREATE SCHEMA ${DB_NAME}" | MYSQL_PWD=root mysql -uroot
        echo "GRANT DELETE,INSERT,SELECT,UPDATE ON ${DB_NAME}.* to ${DB_USER}@localhost identified by '${DB_PASS}'" | MYSQL_PWD=root mysql -uroot
        zcat /tmp/rxx.sql.gz | MYSQL_PWD=root mysql -uroot rxx
        echo -e "\e[32m[OK]\e[0m";
    fi 
    external_ip=$(cat /vagrant/config.yml | grep vagrant_ip | cut -d' ' -f2 | xargs)
    echo -e "\n  Add the following line to your host file:"
    echo -e "    \e[32;1m${external_ip}      ${SITE_DOMAIN}\e[0m\n"
    echo -e "  Access the site at:\n    \e[32;1mhttps://${SITE_DOMAIN}\e[0m\n"
    echo -e "    Site Admin:   \e[33;1madmin\e[0m"
    echo -e "    Pass:         \e[33;1m777\e[0m\n"
}

function i18n {
    ./bin/console translation:update --force en
    ./bin/console translation:update --force de
    ./bin/console translation:update --force fr
    ./bin/console translation:update --force es
    sed -i 's/<target>__/<target>/'                       ./translations/messages.en.xlf
    sed -i 's/<target><!\[CDATA\[__/<target><!\[CDATA\[/' ./translations/messages.en.xlf
}
