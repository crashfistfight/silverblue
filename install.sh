#! /usr/bin/env bash

# shellcheck disable=SC1090,SC2154,SC2034

# vars
user=$(id --user --name 1000)

# functions
source_scripts() {
    for script in "${scripts[@]}"; do
        echo "Running scripts/$script..."
        source scripts/"$script"
    done

    unset scripts
}

# only start as root
if [[ "$EUID" = "0" ]]; then
    # check if rpm-ostree is idle
    while ! rpm-ostree status | grep --only-matching --quiet 'idle'; do
        echo 'Waiting for rpm-ostree...'
        sleep 5
    done

    # start install
    source hosts/"$HOSTNAME"
    source_scripts

    # fix permissions
    chown --recursive "$user":"$user" /var/home/"$user"

    # cleanup temporary variables
    unset user
    
    # show message
    echo "Please reboot..."
fi