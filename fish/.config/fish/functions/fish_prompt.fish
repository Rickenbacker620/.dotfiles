function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status
    set -l normal (set_color normal)
    set -l shadow (set_color $fish_color_comment)

    set -l color_cwd $fish_color_cwd
    set -l suffix '>'

    if fish_is_root_user
        set color_cwd $fish_color_cwd_root
        set suffix '#'
    end

    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end

    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s $(prompt_login) " " $(set_color $color_cwd) $(prompt_pwd) $normal " " $prompt_status \n $suffix " "
end
