#!/bin/bash

if [ "$EUID" -ne 0 ] ; then
  echo "This script must be run as root."
  exit 1
fi

if [ -e /etc/os-release ]; then
    . /etc/os-release
    LINUX_DIST=$ID
    if [ $LINUX_DIST == archarm ]; then
        LINUX_DIST=arch
    fi
else
    echo "/etc/os-release file not found."
fi

if [ $LINUX_DIST == arch ]; then
    pacman -Syy
    pacman -S sudo --noconfirm

elif [ $LINUX_DIST == debian ]; then
    apt update
    apt install sudo -y
else
    echo "Unsupported package manager"
    exit 1
fi

function create_user() {
    info "Creating user shiro"

    # Check if user already exists
    if id "shiro" &>/dev/null; then
        echo "User shiro already exists"
        return 1
    fi

    # Create user
    if ! useradd -m shiro; then
        echo "Failed to create user shiro"
        return 1
    fi

    # Modify user group
    if [ "$LINUX_DIST" == "arch" ]; then
        usermod -aG wheel shiro
        echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/01-wheel
        chmod 440 /etc/sudoers.d/01-wheel
    elif [ "$LINUX_DIST" == "debian" ]; then
        usermod -aG sudo shiro
        echo "%sudo ALL=(ALL:ALL) ALL" > /etc/sudoers.d/01-sudo
        chmod 440 /etc/sudoers.d/01-sudo
    fi

    # Set password
    echo "Please set password for user shiro"
    until passwd shiro; do
        echo "Password setting failed, please try again"
    done

    echo "User shiro created successfully and added to admin group"
}

create_user