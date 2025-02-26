#!/bin/bash

function center_text() {
    local text="$1 ..."
    local term_width=$(tput cols)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    printf "%*s%s%*s" $padding "" "$text" $padding ""
}

function info() {
    printf "\033[44m%s\033[0m\n" "$(center_text "$1")"
}

function error() {
    printf "\033[41m%s\033[0m\n" "$(center_text "$1")"
}

function check_root() {
    if [ $EUID -ne 0 ]; then
        error "This operation must be run as root"
        exit 1
    fi
}

function check_non_root() {
    if [ $EUID -eq 0 ]; then
        error "This operation must not be run as root"
        exit 1
    fi
}

# Check if sudo is installed
if ! command -v sudo &>/dev/null; then
    error "Please install sudo first."
    exit 1
fi

if [ -e /etc/os-release ]; then
    . /etc/os-release
    LINUX_DIST=$ID
    if [ $LINUX_DIST == archarm ]; then
        LINUX_DIST=arch
    fi
else
    error "/etc/os-release file not found."
fi

# Init or update all git submodules
info "Initializing and updating git submodules"
git submodule update --init --recursive --depth 1


if [ $LINUX_DIST == arch ]; then
    sudo pacman -Syy
    PM_INSTALL="sudo pacman -S --noconfirm --needed"
    AUR_INSTALL="yay --noconfirm"

    ESSENTIAL_PKG="stow git btop highlight curl wget vim fish tmux yazi man zoxide openssh ffmpeg p7zip jq poppler fd ripgrep fzf imagemagick base-devel docker"

    DEV_PKG="qemu-full cmake gdb go clang dotnet-sdk nodejs npm jdk8-openjdk uv rustup postgresql"

    DESKTOP_PKG="hyprland waybar wl-clipboard wofi kitty pipewire wireplumber brightnessctl fcitx5-im bluez bluez-utils hyprpaper power-profiles-daemon mpv libvirt virt-manager noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd ttf-font-awesome powerline powerline-fonts"

elif [ $LINUX_DIST == debian ]; then
    sudo apt-get update
    PM_INSTALL="sudo apt-get install -y"

    ESSENTIAL_PKG="stow git btop highlight curl wget vim fish tmux man zoxide build-essential openssh-client openssh-server docker ca-certificates gnupg"

    DEV_PKG="qemu-system cmake gdb golang clang nodejs default-jdk postgresql"

    DESKTOP_PKG="mpv libvirt virt-install virt-viewer noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd"

else
    error "Unsupported package manager"
    exit 1
fi


function install_essential() {
    check_non_root
    info "Installing Essential Tools"

    if [ $LINUX_DIST == arch ]; then
        # Customize pacman and makepkg configs
        sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
        sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf

        # Comment the NoProgressBar option
        sudo sed -i 's/NoProgressBar/#NoProgressBar/g' /etc/pacman.conf

        # Dont download debug packages
        sudo sed -i '/^OPTIONS=/ s/ debug/ !debug/' /etc/makepkg.conf
    fi

    $PM_INSTALL $ESSENTIAL_PKG

    # AUR
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
    pushd /tmp/yay
        makepkg -si
    popd

    if [ $LINUX_DIST == debian ]; then

        # Rust
        info "Installing Rust"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        . "$HOME/.cargo/env"
        rustup update

        # Yazi
        info "Installing Yazi"
        cargo install --locked yazi-fm yazi-cli

        # Docker
        info "Installing Docker"
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
}

function install_dev() {
    check_non_root
    info "Installing Dev Tools"

    $PM_INSTALL $DEV_PKG

    # if not arch linux, install uv from source

    if [ $LINUX_DIST == debian ]; then

        # UV
        info "Installing uv"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

function install_desktop() {
    check_non_root
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

function setup_config() {

    rm -rf ~/.config
    mkdir -p ~/.config
    stow --adopt */

    setup_fish
    setup_git
    setup_ssh
}

function create_user() {
    check_root
    info "Creating user shiro"

    # Check if user already exists
    if id "shiro" &>/dev/null; then
        info "User shiro already exists"
        return 1
    fi

    # Create user
    if ! useradd -m shiro; then
        error "Failed to create user shiro"
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
    info "Please set password for user shiro"
    until passwd shiro; do
        error "Password setting failed, please try again"
    done

    info "User shiro created successfully and added to admin group"
}

PS3="Please select a configuration (enter the number): "

while true; do
    select opt in "Install essential pkgs" "Install dev pkgs" "Install desktop pkgs" "Create user" "Config" "Exit"; do
        case "$REPLY" in
        1)
            install_essential
            break
            ;;
        2)
            install_dev
            break
            ;;
        3)
            install_desktop
            break
            ;;
        4)
            create_user
            break
            ;;
        5)
            setup_config
            break
            ;;
        6|q|Q)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a valid number or 'q' to quit."
            ;;
        esac
    done
done
