function man --description "wrap the 'man' manual page opener to use color in formatting"

  set -x LESS_TERMCAP_md (set_color --bold bd93f9)
  # end of all formatting:
  set -x LESS_TERMCAP_me (set_color normal)

  # start of standout (inverted colors):
  set -x LESS_TERMCAP_so (set_color --reverse 50fa7b)
  # end of standout (inverted colors):
  set -x LESS_TERMCAP_se (set_color normal)
  # (no change – I like the default)

  # start of underline:
  set -x LESS_TERMCAP_us (set_color --underline f1fa8c)
  # end of underline:
  set -x LESS_TERMCAP_ue (set_color normal)
  # (no change – I like the default)

  command man $argv
end