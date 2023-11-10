#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo" 
    exit 1
fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: ./lamp.sh [--install|-i|--start|-s|--stop|-t|--status|-st|--upgrade|-u|--uninstall|-un]"
    echo ""
    echo "Options:"
    echo "  --install, -i  Install the LAMP stack."
    echo "  --start, -s    Start the LAMP stack."
    echo "  --stop, -t     Stop the LAMP stack."
    echo "  --status, -st  Check the status of the LAMP stack."
    echo "  --upgrade, -u  Upgrade the LAMP stack."
    echo "  --uninstall, -un Uninstall the LAMP stack."
    echo "  --help, -h     Display this help menu."
    exit 0
fi

function install_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        sudo apt update
        sudo apt install apache2 mysql-server php php-fpm -y
    elif [[ $(which yum 2>/dev/null) ]]; then
        sudo yum update
        sudo yum install httpd mariadb-server php php-fpm -y
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

function start_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        sudo systemctl start apache2
        sudo systemctl start mysql
        php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
        php_fpm_service="php${php_version}-fpm"
        sudo systemctl start $php_fpm_service
    elif [[ $(which yum 2>/dev/null) ]]; then
        sudo systemctl start httpd
        sudo systemctl start mariadb
        sudo systemctl start php-fpm.service
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

function stop_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        sudo systemctl stop apache2
        sudo systemctl stop mysql
        php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
        php_fpm_service="php${php_version}-fpm"
        sudo systemctl stop $php_fpm_service
    elif [[ $(which yum 2>/dev/null) ]]; then
        sudo systemctl stop httpd
        sudo systemctl stop mariadb
        sudo systemctl stop php-fpm.service
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

function status_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        echo "Apache2: $(sudo systemctl is-active apache2)"
        echo "MySQL: $(sudo systemctl is-active mysql)"
        php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
        php_fpm_service="php${php_version}-fpm"
        echo "PHP-FPM: $(sudo systemctl is-active $php_fpm_service)"
    elif [[ $(which yum 2>/dev/null) ]]; then
        echo "HTTPD: $(sudo systemctl is-active httpd)"
        echo "MariaDB: $(sudo systemctl is-active mariadb)"
        echo "PHP-FPM: $(sudo systemctl is-active php-fpm.service)"
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

function upgrade_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        sudo apt update
        sudo apt upgrade -y
    elif [[ $(which yum 2>/dev/null) ]]; then
        sudo yum update -y
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

function uninstall_lamp() {
    if [[ $(which apt 2>/dev/null) ]]; then
        sudo apt remove apache2 mysql-server php php-fpm -y
    elif [[ $(which yum 2>/dev/null) ]]; then
        sudo yum remove httpd mariadb-server php php-fpm -y
    else
        echo "Your distro is not supported."
        exit 1
    fi
}

case "$1" in
    --install|-i)
        install_lamp
        ;;
    --start|-s)
        start_lamp
        ;;
    --stop|-t)
        stop_lamp
        ;;
    --status|-st)
        status_lamp
        ;;
    --upgrade|-u)
        upgrade_lamp
        ;;
    --uninstall|-un)
        uninstall_lamp
        ;;
    *)
        echo "Invalid option. Use --help for more information."
        ;;
esac