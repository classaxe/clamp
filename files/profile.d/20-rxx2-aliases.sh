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

        echo -en "  Installing GeoIP Database                           "
        sudo mkdir -p /usr/local/share/GeoIP > /dev/null 2>&1;
        sudo chown vagrant:vagrant /usr/local/share/GeoIP > /dev/null 2>&1;
        /srv/www/rxx/bin/console geoip2:update  > /dev/null 2>&1;
        echo -e "\e[32m[OK]\e[0m";

        echo -en "  Adding Mysql DSN Connection string to .env file     "
        sed -i 's/mysql:\/\/db_user:db_password@127.0.0.1:3306\/db_name/mysql:\/\/rxx:clamp_rxx_777@localhost:3306\/rxx?charset=UTF8/' .env
        echo -e "\e[32m[OK]\e[0m";
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
    sudo vhost add -n ${SITE_DOMAIN} -d /srv/www/rxx/public -p 7.2 -f > /dev/null 2>&1
    sudo service apache2 restart > /dev/null 2>&1
    echo -e "\e[32m[OK]\e[0m";

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


    external_ip=$(cat /vagrant/config.yml | grep vagrant_ip | cut -d' ' -f2 | xargs)
    echo -e "\n  Add the following line to your host file:"
    echo -e "    \e[32;1m${external_ip}      ${SITE_DOMAIN}\e[0m\n"
    echo -e "  Access the site at:\n    \e[32;1mhttps://${SITE_DOMAIN}\e[0m\n"
    echo -e "    Site Admin:   \e[33;1madmin\e[0m"
    echo -e "    Pass:         \e[33;1m777\e[0m\n"
}

