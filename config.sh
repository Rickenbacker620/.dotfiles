#!/bin/bash

if [ -z "$PM" ]; then
    PM="pacman"
fi

echo "Using package manager: $PM"

if [ "$PM" = "pacman" ]; then
    PM_INSTALL="sudo pacman -Sy --noconfirm --needed"
    DEV_PKG="base-devel"
    OPENSSH_PKG="openssh"
    PYENV_BUILD_PKG="base-devel openssl zlib xz tk"
    LANG_PKGS="pyenv go clang dotnet-sdk nodejs jdk8-openjdk"
elif [ "$PM" = "apt" ]; then
    PM_INSTALL="sudo apt-get install -y"
    DEV_PKG="build-essential"
    OPENSSH_PKG="openssh-server"
    PYENV_BUILD_PKG="build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
    LANG_PKGS="golang clang dotnet-sdk-7.0 nodejs openjdk-8-jdk"
else
    echo "Unsupported package manager: $PM"
    exit 1
fi

function mklink() {
    rm -rf ~/$2
    ln -sf $PWD/$1 ~/$2
}

function info() {
    echo -e "\033[96m$1 ...\033[0m"
}

function install_base() {
    info "Installing Base Tools"

    $PM_INSTALL git curl wget vim fish tmux ranger man $OPENSSH_PKG
}

function install_dev() {
    info "Installing Dev Tools"

    $PM_INSTALL $DEV_PKG cmake gdb
}

function setup_fish() {
    info "Setting up fish shell"

    mklink fish .config/fish
    chsh -s $(which fish)
    fish -c "set -U fish_greeting"
}

function setup_git() {
    info "Setting up git"

    git config --global user.email "1057558227@qq.com"
    git config --global user.name "Rickenbacker620"
}

function setup_vim() {
    info "Setting up vim"

	git clone https://github.com/dracula/vim.git $PWD/.vim/pack/themes/start/dracula
	git clone https://github.com/itchyny/lightline.vim.git $PWD/.vim/pack/themes/start/lightline

    mklink .vim .vim
    mklink .vimrc .vimrc
    fish -c "set -U EDITOR vim"
}

function setup_tmux() {
    info "Setting up tmux"

    git clone https://github.com/tmux-plugins/tpm.git $PWD/.tmux/plugins/tpm

    mklink .tmux .tmux
    mklink .tmux.conf .tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
}

function setup_ranger() {
    info "Setting up ranger"

    mklink ranger .config/ranger
}

function setup_base() {
    setup_fish
    setup_git
    setup_vim
    setup_tmux
    setup_ranger
}

function setup_languages() {
    info "Setting up languages"

    $PM_INSTALL $LANG_PKGS

    curl https://pyenv.run | bash

    $PM_INSTALL $PYENV_BUILD_PKG

    # pyenv
    fish -c "set -Ux PYENV_ROOT $HOME/.pyenv"
    fish -c "fish_add_path $PYENV_ROOT/bin"
}

PS3="Please select a configuration (enter the number): "

while true; do
    select opt in "mini" "dev" "dev-full" "exit"; do
        case "$REPLY" in
        1)
            install_base
            setup_base
            break
            ;;
        2)
            install_base
            install_dev
            setup_base
            break
            ;;
        3)
            install_base
            install_dev
            setup_base
            setup_languages
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
