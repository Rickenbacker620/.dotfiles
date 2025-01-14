#!/bin/bash

if [ "$EUID" -ne 0 ] && ! groups | grep -qE 'sudo|wheel'; then
  echo "This script must be run as root or by a user who can execute sudo."
  exit 1
fi

if [ -e /etc/os-release ]; then
    . /etc/os-release
    LINUX_DIST=$ID
else
    echo "/etc/os-release file not found."
fi

if [ $LINUX_DIST == arch ]; then
    sudo pacman -Syy
    PM_INSTALL="sudo pacman -S --noconfirm --needed"
    AUR_INSTALL="yay --noconfirm"

    BASE_PKG="stow git btop highlight curl wget neovim fish tmux yazi man zoxide openssh ffmpeg p7zip jq poppler fd ripgrep fzf imagemagick base-devel docker"

    DEV_PKG="qemu-full cmake gdb go clang dotnet-sdk nodejs npm jdk8-openjdk uv rustup"

    DESKTOP_PKG="hyprland waybar wl-clipboard wofi kitty pipewire wireplumber brightnessctl fcitx5-im bluez bluez-utils hyprpaper power-profiles-daemon mpv libvirt virt-manager noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd ttf-font-awesome powerline powerline-fonts"

elif [ $LINUX_DIST == debian ]; then
    sudo apt-get update
    PM_INSTALL="sudo apt-get install -y"

    BASE_PKG="stow git btop highlight curl wget neovim fish tmux man zoxide build-essential openssh-client openssh-server docker ca-certificates"

    DEV_PKG="qemu-system cmake gdb golang clang nodejs default-jdk"

    DESKTOP_PKG="mpv libvirt virt-install virt-viewer noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd"

else
    echo "Unsupported package manager"
    exit 1
fi


function info() {
    echo -e "\033[96m$1 ...\033[0m"
}

function install_base() {
    info "Installing Base Tools"

    $PM_INSTALL $BASE_PKG

    # AUR
    if [ $LINUX_DIST == arch ]; then
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
        pushd /tmp/yay
            makepkg -si
        popd
    fi

    if [ $LINUX_DIST == debian ]; then

        # Yazi
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        . "$HOME/.cargo/env"
        rustup update
        cargo install --locked yazi-fm yazi-cli

        # Docker
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
}

function install_dev() {
    info "Installing Dev Tools"

    $PM_INSTALL $DEV_PKG

    # if not arch linux, install uv from source

    if [ $LINUX_DIST == debian ]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

function install_desktop() {
    info "Installing Desktop Environment"

    $PM_INSTALL $DESKTOP_PKG

    if [ $LINUX_DIST == arch ]; then
        $AUR_INSTALL visual-studio-code-bin google-chrome
    fi
}

function setup_fish() {
    info "Setting up fish shell"

    chsh -s $(which fish)
    fish -c "set -U fish_greeting"
}

function setup_git() {
    info "Setting up git"

    git config --global user.email "fu78sion@gmail.com"
    git config --global user.name "Rickenbacker620"
}

function setup_ssh() {
    info "Setting up ssh"

    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi

    read -p "Please Enter PubKey: "

    echo $REPLY >> ~/.ssh/authorized_keys
}

function setup_vim() {
    info "Setting up vim"

    if command -v nvim &>/dev/null; then
        fish -c "set -Ux EDITOR nvim"
    else
        fish -c "set -Ux EDITOR vim"
    fi
}

function setup_config() {

    rm -rf ~/.config
    mkdir -p ~/.config
    stow --adopt */

    setup_fish
    setup_git
    setup_ssh
    setup_vim
}

PS3="Please select a configuration (enter the number): "

while true; do
    select opt in "Install base pkgs" "Install dev pkgs" "Install desktop pkgs" "Config" "Exit"; do
        case "$REPLY" in
        1)
            install_base
            break
            ;;
        2)
            install_base
            install_dev
            break
            ;;
        3)
            install_base
            install_dev
            install_desktop
            break
            ;;
        4)
            setup_config
            break
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a valid number."
            ;;
        esac
    done
done
