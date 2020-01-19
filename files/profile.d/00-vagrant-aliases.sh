# Useful Aliases
alias a2r='service apache2 restart'
alias lh='ls -alh'
alias sudo='sudo '
alias mem='free | awk '\''/Mem/{printf("Memory used: %.2f%"), $3/$2*100} /buffers\/cache/{printf(", buffers: %.2f%\n"), 100-($4/($3+$4)*100)}'\'''
alias www='cd /srv/www'


# Use like this:
# addtocrontab "0 0 1 * *" "echo hello"
function addtocrontab () {
    local frequency=$1
    local command=$2
    local job="$frequency $command"
    cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
}


# Vagrant helper functions and aliases:
function vhelp {
    local _versions=''
    local _vhost_sites="$(vhost sites | sed 's/$/\\n/g' | tr -d '\n')"
    local config_php
    source /vagrant/config_php.sh
    for i in "${config_php[@]}"; do
        arr=(${i// / })
        phpv=${arr[0]}
        phpn=${arr[1]}
        phpv_x=${phpv}'     '
        phpn_x=${phpn}'     '
        line="    * PHP ${phpv_x:0:6}      - alias php${phpn}"
        _versions="${_versions}${line}\n"
    done;
    local external_ip=$(cat /vagrant/config.yml | grep vagrant_ip | cut -d' ' -f2 | xargs)
    text=$(sed "s|###php_versions###|${_versions}|g" /vagrant/files/welcome.txt | sed "s|###vhost_sites###|${_vhost_sites}|g" | sed "s|###external_ip###|${external_ip}|g");
    echo -e "$text"
}

function vstatus {
    echo -e "\n\033[1;32mvstatus - Vagrant Status\033[0;32m"
    echo -e "  Disk Used:      `df -h --output='pcent' / | tail -n1` (Vagrant) `df -h --output='pcent' /vagrant | tail -n1` (Host)"
    echo -e "  `free | awk '/Mem/{printf(\"Memory used:     %.0f% (RAM)\"), $3/$2*100} /buffers\/cache/{printf(\"      %.0f% (Buffers)\"), 100-($4/($3+$4)*100)}'`\n"
    echo -e "\n\033[1;32mService Status \033[0m"
    echo -e "  \033[32mApache2 Status:   $(if [[ $(sudo service apache2      status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    echo -e "  \033[32mCron Status:      $(if [[ $(sudo service cron         status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    echo -e "  \033[32mMemcached Status: $(if [[ $(sudo service memcached    status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    echo -e "  \033[32mMysql Status:     $(if [[ $(sudo service mysql        status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    echo -e "  \033[32mNTP Status:       $(if [[ $(sudo service ntp          status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    echo -e "  \033[32mRedis Status:     $(if [[ $(sudo service redis-server status | grep 'active (running)') != '' ]]; then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    if [ -f /etc/default/varnish ]; then
        echo -e "  \033[32mVarnish Status:   $(if [[ $(sudo pgrep varnishd) != '' ]];                                        then echo '\033[1;32mOK\033[0;32m'; else echo '\033[1;31mStopped\033[0;32m'; fi)\033[0m"
    fi
    echo -e "\033[0m"
}

