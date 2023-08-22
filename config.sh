#!/bin/bash

if [ -e /etc/os-release ]; then
    . /etc/os-release
    LINUX_DIST=$ID
else
    echo "/etc/os-release file not found."
fi

if [$LINUX_DIST == arch]; then
    sudo pacman -Syy
    PM_INSTALL="sudo pacman -S --noconfirm --needed"
    AUR_INSTALL="paru -S --noconfirm"
    DEV_PKG="base-devel qemu-full"
    OPENSSH_PKG="openssh"
    PYENV_BUILD_PKG="openssl zlib xz tk"
    LANG_PKGS="cmake gdb go clang dotnet-sdk nodejs jdk8-openjdk"
    DESKTOP_PKG="bspwm sxhkd rofi polybar feh mpv xorg-server xorg-xinit xorg-xrandr noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd papirus-icon-theme"

elif [$LINUX_DIST == debian]; then
    sudo apt-get update
    PM_INSTALL="sudo apt-get install -y"
    DEV_PKG="build-essential qemu-system"
    OPENSSH_PKG="openssh-server"
    PYENV_BUILD_PKG="libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
    LANG_PKGS="cmake gdb golang clang nodejs default-jdk"

else
    echo "Unsupported package manager"
    exit 1
fi


function info() {
    echo -e "\033[96m$1 ...\033[0m"
}

function install_base() {
    info "Installing Base Tools"

    $PM_INSTALL stow git btop highlight curl wget vim fish tmux ranger man zoxide $OPENSSH_PKG

    # AUR
    if [ $LINUX_DIST == arch ]; then
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        pushd /tmp/paru
            makepkg -si
        popd
    fi
}

function install_dev() {
    info "Installing Dev Tools"

    $PM_INSTALL $DEV_PKG $LANG_PKGS

    curl https://pyenv.run | bash

    $PM_INSTALL $PYENV_BUILD_PKG

    # pyenv
    fish -c "set -Ux PYENV_ROOT $HOME/.pyenv"
    fish -c "fish_add_path $HOME/.pyenv/bin"
}

function install_desktop() {
    info "Installing Desktop Environment"

    $PM_INSTALL $DESKTOP_PKG

    if [$LINUX_DIST == arch]; then
        $AUR_INSTALL visual-studio-code-bin google-chrome
    fi
}

function setup_fish() {
    info "Setting up fish shell"

    chsh -s $(which fish)
    fish -c "set -U fish_greeting"
    fish -c "set -Ux RANGER_LOAD_DEFAULT_RC false"
    fish -c "fish_vi_key_bindings"
}

function setup_git() {
    info "Setting up git"

    git config --global user.email "1057558227@qq.com"
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

    mkdir -p ~/.cache/vim/undo
    fish -c "set -Ux EDITOR vim"
}

function setup_config() {

    mkdir -p ~/.config
    stow */

    setup_fish
    setup_git
    setup_ssh
    setup_vim
}

PS3="Please select a configuration (enter the number): "

while true; do
    select opt in "mini" "dev" "full" "exit"; do
        case "$REPLY" in
        1)
            install_base
            setup_config
            break
            ;;
        2)
            install_base
            install_dev
            setup_config
            break
            ;;
        3)
            install_base
            install_dev
            install_desktop
            setup_config
            break
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a valid number."
            ;;
        esac
    done
done
