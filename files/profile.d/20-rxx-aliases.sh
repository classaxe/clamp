alias rxx='cd /srv/www/cam/dx/ndb'

function installRxx {
    echo -e "\n\e[32m**************"
    echo -e "* installRxx *"
    echo -e "**************\e[0m"

    SITE_DOMAIN=dev.classaxe.com
    DB_USER=rxx
    DB_PASS=clamp_rxx_777
    DB_NAME=rxx

    if [ ! -d /srv/www/cam ] ; then
        echo -en "  Cloning RXX Codebase                                "
        mkdir -p /srv/www/cam/dx/ndb
        git clone https://github.com/classaxe/rxx.git /srv/www/cam/dx/ndb          > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";
    else
        echo -e "\e[32mSite already present - to completely rebuild it execute these commands:"
        echo -e "\e[33;1m  cd /srv/www; rm -rf /srv/www/cam\e[0m\e[32m\e[0m\n"
        echo -en "  Updating RXX Codebase                               "
        cd /srv/www/cam/dx/ndb
        git pull origin master > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";
    fi

    echo -en "  Setting up website       \e[33;1m${SITE_DOMAIN}\e[0m           "
    sudo vhost add -n ${SITE_DOMAIN} -d /srv/www/cam -p 7.2 -f > /dev/null 2>&1
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
    echo -e "  Access the site at:\n    \e[32;1mhttps://${SITE_DOMAIN}/dx/ndb\e[0m\n"
    echo -e "  Admin site details:\n    \e[32;1mhttps://${SITE_DOMAIN}/dx/ndb/rna/logon\e[0m\n"
    echo -e "    Site Admin:   \e[33;1madmin\e[0m"
    echo -e "    Pass:         \e[33;1m777\e[0m\n"
}

