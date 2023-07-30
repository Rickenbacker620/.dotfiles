fish_config theme choose "Dracula"

function fish_command_not_found
    echo -e "Oops! Command \033[31m$argv[1]\033[0m not found"
end

if type -q pyenv
    pyenv init - | source
    status --is-interactive; and pyenv virtualenv-init - | source
end