function installCiyt {
    echo -e "\n\e[32m***************"
    echo -e "* installCiyt *"
    echo -e "***************\e[0m"

    SITE_DOMAIN=dev.churchesinyourtown.com
    DB_USER=ciyt
    DB_PASS=clamp_ciyt_777
    DB_NAME=ecclesiact

    sudo service apache2 stop
    cd /srv/www

    if [ ! -d /srv/www/ciyt ] ; then
        echo -e "\e[32mWARNING: This first step takes a while, because 1GB of assets are downloaded\e[0m\n"

        echo -en "  Setting up base site for \e[33;1m${SITE_DOMAIN}\e[0m "
        git clone https://github.com/classaxe/ciyt_site_essentials /srv/www/ciyt           > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";

        echo -en "  Installing Ecclesiact                               "
        git clone https://github.com/classaxe/ecclesiact           /srv/www/ciyt/shared    > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";

        echo -en "  Running composer install                            "
        cd /srv/www/ciyt/shared
        composer install > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";

    else
        echo -e "\e[32mSite already present - to completely rebuild it:"
        echo -e "\e[33;1m  cd /srv/www; rm -rf /srv/www/ciyt\e[0m\e[32m\e[0m\n"
        echo -en "  Updating Ecclesiact                                 "
        cd /srv/www/ciyt/shared
        git pull origin master > /dev/null 2>&1
        echo -e "\e[32m[OK]\e[0m";
    fi

    echo -en "  Setting up website       \e[33;1m${SITE_DOMAIN}\e[0m "
    sudo vhost add -n ${SITE_DOMAIN} -d /srv/www/ciyt -p 7.2 -f > /dev/null 2>&1
    sudo service apache2 restart > /dev/null 2>&1
    echo -e "\e[32m[OK]\e[0m";

    echo -en "  Fetching Database files                             "
    mkdir -p /srv/www/ciyt/sql
    cd       /srv/www/ciyt/sql
    rm -f ecclesiact.sql.gz ecclesiact_media.sql.gz ciyt.sql.gz

    wget https://www.ecclesiact.com/export/ecclesiact.sql.gz       > /dev/null 2>&1
    wget https://www.ecclesiact.com/export/ecclesiact_media.sql.gz > /dev/null 2>&1
    wget https://www.ecclesiact.com/export/ciyt.sql.gz             > /dev/null 2>&1
    cd     /srv/www/ciyt
    echo -e "\e[32m[OK]\e[0m";

    echo -en "  Setting up Database                                 "
    export MYSQL_PWD=root;
    echo "DROP SCHEMA IF EXISTS ${DB_NAME}; DROP SCHEMA IF EXISTS ${DB_NAME}_media" | mysql -uroot
    echo "CREATE SCHEMA ${DB_NAME}; CREATE SCHEMA ${DB_NAME}_media" | mysql -uroot
    echo "GRANT DELETE,INSERT,SELECT,UPDATE ON ${DB_NAME}.* to ${DB_USER}@localhost identified by '${DB_PASS}'" | mysql -uroot
    echo "GRANT DELETE,INSERT,SELECT,UPDATE ON ${DB_NAME}_media.* to ${DB_USER}@localhost identified by '${DB_PASS}'" | mysql -uroot
    zcat /srv/www/ciyt/sql/ecclesiact.sql.gz       | mysql -uroot ${DB_NAME}
    zcat /srv/www/ciyt/sql/ecclesiact_media.sql.gz | mysql -uroot ${DB_NAME}_media
    zcat /srv/www/ciyt/sql/ciyt.sql.gz             | mysql -uroot ${DB_NAME}
    export MYSQL_PWD='';
    echo -e "\e[32m[OK]\e[0m";

    echo -en "  Setting up crontab                                  "
    addtocrontab "* * * * *" "wget https://dev.churchesinyourtown.com/cron/ -q --no-check-certificate -O /dev/null"
    echo -e "\e[32m[OK]\e[0m";

    external_ip=$(cat /vagrant/config.yml | grep vagrant_ip | cut -d' ' -f2 | xargs)
    echo -e "\n  Add the following line to your host file:"
    echo -e "    \e[32;1m${external_ip}      ${SITE_DOMAIN}\e[0m\n"
    echo -e "  Access the site at:\n    \e[32;1mhttps://${SITE_DOMAIN}\e[0m\n"
    echo -e "  Admin site details:\n    \e[32;1mhttps://${SITE_DOMAIN}/signin\e[0m\n"
    echo -e "    Site Admin:   \e[33;1madmin\e[0m"
    echo -e "    Pass:         \e[33;1mPassword123\e[0m\n"
    echo -e "    Master Admin: \e[33;1mmasteradmin\e[0m"
    echo -e "    Pass:         \e[33;1mPassword123\e[0m\n"
}
