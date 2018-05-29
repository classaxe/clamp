# CLAMP (ClassAxe LAMP) Development Environment

Jump to [Special Thanks](#special-thanks) | [Goal](#goal) | [Requirements](#requirements) | [Setup](#setup) | [Configuration](#configuration) | [Change History](#change-history)

### Special Thanks
The Vagrant development contained in this package was forked from Demac Media's 'Vagrant-Lamp'.
The original code was designed to support Magento 1 and Magento 2 projects and it may be found
at https://github.com/DemacMedia/vagrant-lamp

Credit and grateful thanks go to [**Michael Kreitzer**](https://github.com/reztierk) who developed that code initially
and to [**Demac Media**](https://demacmedia.com) who chose to make it freely available throught Github.


### Goal
The goal of this project is to create an easy to use, reliable development environment to support
the Ecclesiact website platform, and for ongoing development of the community-based [**Churches In Your Town**](https://churchesinyourtown.com) website project
and other projects created and maintained by the author, such as the **RNA / REU / RWW** (aka 'RXX')](https://www.classaxe.com/dx/ndb) NDB Radio beacon logging site


### Requirements

- [Vagrant 2.0.0+](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)


### Setup

    # Install git if it isn't there already

    # Change to your home directory and clone the clamp development environment
    git clone https://github.com/Classaxe/clamp.git
    cd clamp

    # Copy example.config.yml to config.yml and edit options
    cp example.config.yml config.yml
    vim config.yml

### Configuration
-   Guest Host Entries:
    -   Add host entries to files/hosts.txt to have them added to Guest machine on provisioning
-   config.yml settings
    -   vagrant_hostname: Hostname on Guest VM
        OPTIONAL - can leave default `dev.classaxe.com`
    -   vagrant_machine_name: Vagrant Machine Name, used for creating unique VM
        OPTIONAL - can leave default `clamp`
    -   vagrant_ip: IP addressed used to access Guest VM from Local machine
        OPTIONAL - can leave default `192.168.77.77`
    -   vagrant_public_ip: Public IP address of VM
        OPTIONAL - recommended leave defualt `empty`
    -   vagrant_synced_folders: Shared Folders from HOST machine to Guest
        -   local_path: Path on Host machine to share
        -   destination: Path on Guest machine to mount share
        -   type: Share Type \[[nfs](https://www.vagrantup.com/docs/synced-folders/nfs.html)|[smb](https://www.vagrantup.com/docs/synced-folders/smb.html)|[rsync](https://www.vagrantup.com/docs/synced-folders/rsync.html)\]
            OPTIONAL - recommended leave default as empty.  Mac OS users may use nfs but not recommended for the mysql share as nfs bind may run out of connections
        -   create: Create directory on HOST machine if it doesn't exist
            OPTIONAL - recommended leave default `true`
        ```
        # Example of Multiple Shared Folders
        vagrant_synced_folders:
          - local_path: ~/clamp/www
            destination: /srv/www
            type: nfs 
            create: true

          - local_path: ~/clamp/mysql
            destination: /srv/mysql
            type:
            create: true
            owner: 500      # mysql user  not created yet, but will have this id when the box is provisioned
            group: 500      # mysql group not created yet, but will have this id when the box is provisioned

          - local_path: ~/clamp/backup
            destination: /srv/backup
            type: nfs
            create: true
        ```
    -   vagrant_memory: Memory to assign to VM
        OPTIONAL - can leave default `4096`
    -   vagrant_cpus: CPU Cores to assign to VM
        OPTIONAL - can leave default `2`

#### The following are installed:
-   Apache2 v2.4 with mpm\_event
-   Percona 5.6 (MySQL Server and Client)
-   Varnish 4
-   Redis
-   PHP-FPM 5.4, 5.5, 5.6, 7.0, 7.1 and 7.2 with Xdebug (via PHPFARM)
-   ElasticSearch 2.4.6
-   RabbitMq 3.5.7
-   Solr 3.4.0, 3.5.0 & 3.6.2
-   htop
-   dos2unix
-   smem
-   strace
-   lynx
-   mailhog

#### The following Extra Tools are available:
-   Composer
-   N98-Magerun and N98-Magerun2
-   modman
-   PHPUnit
-   redis
    - Add / Remove or List Redis instances

        ```Usage: sudo redis add|remove|list -n name [-p port] [-s save]```
-   vhost
    - Add / Remove / List Apache virtualhost entries

        ```Usage: sudo vhost add|remove|list|sites -d DocumentRoot -n ServerName -p PhpVersion [-a ServerAlias] [-s CertPath] [-c CertName] [-f]```
-   solr
    - Add / Remove Solr core entries

        ```Usage: sudo solr add|remove|list -n name [-v version]```
-   mysql-sync
    - Sync Remote Database to VM Mysql instance

        ```Usage: mysql-sync -i remote-ip -p remote-port -u remote-username -d remote-database```


#### Completing the installation:
    # Run Vagrant Up to download and provision the VM
    vagrant up

    # Once the system has booted, connect to the terminal inside with this:
    vagrant ssh

    # To install the Churches In Your Town (CIYT) site, type installCiyt in the vagrant terminal

    # To install the RXX NDB Radio Beacon Logging software, type installRxx in the vagrant terminal

## Changelog:
See [CHANGELOG.md](CHANGELOG.md) for the full change history
