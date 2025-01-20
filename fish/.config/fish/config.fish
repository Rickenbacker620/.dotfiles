fish_config theme choose "Dracula"

if test (tty) = "/dev/tty1"
    exec Hyprland
end

function fish_command_not_found
    echo -e "Oops! Command \033[31m$argv[1]\033[0m not found"
end

bind -M insert \cf forward-char

if status --is-interactive
    abbr --add dotdot --regex '^\.\.+$' --function multicd

    if type -q zoxide
        zoxide init fish | source
    end
end