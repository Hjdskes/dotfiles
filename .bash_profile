if [[ -d "$HOME/.local/bin" ]] ; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Don't put duplicate lines or lines starting with space in the
# history.
export HISTCONTROL=ignoreboth

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export EDITOR="vim"
export PAGER="less"
