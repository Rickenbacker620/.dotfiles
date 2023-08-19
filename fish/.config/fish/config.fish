fish_config theme choose "Dracula"

# Start X at login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

function fish_command_not_found
    echo -e "Oops! Command \033[31m$argv[1]\033[0m not found"
end

if type -q pyenv
    pyenv init - | source
end
