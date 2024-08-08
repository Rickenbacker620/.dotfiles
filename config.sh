#!/bin/bash

if [ -e /etc/os-release ]; then
    . /etc/os-release
    LINUX_DIST=$ID
else
    echo "/etc/os-release file not found."
fi

if [ $LINUX_DIST == arch ]; then
    sudo pacman -Syy
    PM_INSTALL="sudo pacman -S --noconfirm --needed"
    AUR_INSTALL="paru -S --noconfirm"

    BASE_PKG="stow git btop highlight curl wget neovim fish tmux ranger man zoxide openssh base-devel"

    DEV_PKG="qemu-full cmake gdb go clang dotnet-sdk nodejs jdk8-openjdk"

    PYENV_BUILD_PKG="openssl zlib xz tk"

    DESKTOP_PKG="hyprland waybar wofi kitty pulseaudio hyprpaper power-profiles-daemon mpv libvirt virt-install virt-viewer noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd ttf-font-awesome powerline powerline-fonts "

    SERVER_PKG="cockpit cockpit-storaged cockpit-machines"

elif [ $LINUX_DIST == debian ]; then
    sudo apt-get update
    PM_INSTALL="sudo apt-get install -y"

    BASE_PKG="stow git btop highlight curl wget neovim fish tmux ranger man zoxide build-essential  openssh-client"

    DEV_PKG="qemu-system cmake gdb golang clang nodejs default-jdk"

    PYENV_BUILD_PKG="libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"

    DESKTOP_PKG="mpv libvirt virt-install virt-viewer noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd"

    SERVER_PKG="cockpit cockpit-storaged cockpit-machines openssh-server"

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
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        pushd /tmp/paru
            makepkg -si
        popd
    fi
}

function install_dev() {
    info "Installing Dev Tools"

    $PM_INSTALL $DEV_PKG

    curl https://pyenv.run | bash

    $PM_INSTALL $PYENV_BUILD_PKG

    # pyenv
    fish -c "set -Ux PYENV_ROOT $HOME/.pyenv"
    fish -c "fish_add_path $HOME/.pyenv/bin"
}

function install_desktop() {
    info "Installing Desktop Environment"

    $PM_INSTALL $DESKTOP_PKG

    if [ $LINUX_DIST == arch ]; then
        $AUR_INSTALL visual-studio-code-bin google-chrome
    fi
}

function install_server() {
    info "Installing Server Environment"

    $PM_INSTALL $SERVER_PKG
}

function setup_fish() {
    info "Setting up fish shell"

    chsh -s $(which fish)
    fish -c "set -U fish_greeting"
    fish -c "set -Ux RANGER_LOAD_DEFAULT_RC false"
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
    select opt in "mini" "dev" "desktop" "server" "exit"; do
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
            install_base
            install_dev
            install_server
            setup_config
            exit 0
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
