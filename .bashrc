# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Append to the history file, don't overwrite it
shopt -s histappend

# Bash won't get SIGWINCH if another process is in the
# foreground.  Enable checkwinsize so that Bash will check
# the window size when it regains control and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Disable completion when the input buffer is empty, i.e.,
# hitting tab and waiting a long time for bash to expand all
# of $PATH.
shopt -s no_empty_cmd_completion

# Alias definitions.
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases

# Prompt.
PROMPT_COMMAND=__prompt_command
function __prompt_command() {
  local RED="\e[31m"
  local GREEN="\e[32m"
  local BLUE="\e[34m"
  local RESET="\e[0m"

  #if [[ $? -ne 0 ]]; then
  #  local EXIT="$RED"
  #else
  #  local EXIT="$GREEN"
  #fi

  if [[ -n "$IN_NIX_SHELL" ]]; then
    local PROMPT='λ'
  else
    local PROMPT='>'
  fi

  local PRE="\n$BLUE\w$RESET " 
  local FORMAT="%s$RESET "
  local POST="\t\n $PROMPT "

  if hash __git_ps1 2>/dev/null; then
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=0
    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_DESCRIBE_STYLE=branch
    GIT_PS1_SHOWUPSTREAM=auto
    
    __git_ps1 "$PRE" "$POST" "$FORMAT"
  else
    PS1="$PRE$POST"
  fi
}

# Add direnv hook for Bash, has to be after other settings
# that manipulate the prompt.
if hash direnv 2>/dev/null; then
  eval "$(direnv hook bash)"

  # Automatically set up a directory for use with Nix through
  # direnv.
  function nixify() {
    if [ ! -e ./.envrc ]; then
      echo "use nix" > .envrc
      direnv allow
    fi
    if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
      cat > default.nix <<EOF
with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    bashInteractive
  ];
}
EOF
      ${EDITOR:-vim} default.nix
    fi
  }
fi

# Colorise man pages.
function man() {
  env \
  LESS_TERMCAP_md=$'\e[0;33m'    \
  LESS_TERMCAP_me=$'\e[0m'       \
  LESS_TERMCAP_so=$'\e[1;31;34m' \
  LESS_TERMCAP_se=$'\e[0m'       \
  LESS_TERMCAP_us=$'\e[0;32m'    \
  LESS_TERMCAP_ue=$'\e[0m'       \
  man "$@"
}

# Generate a pseudorandom string.
function rstring() {
  LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | fold -w ${1:-32} | head -n 1
}

# Go up in the $pwd up to the given directory name.
function upto() {
  if [ -z "$1" ]; then
      return
  fi
  local upto=$1
  cd "${PWD/\/$upto\/*//$upto}"
}

function _upto() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local d=${PWD//\//\ }
  COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}
complete -F _upto upto

# Conveniently extract an archive.
function extract() {
  if [ "$#" -ne 1 ]; then
    printf "Usage: %s FILE" "$0" >&2
    return 1
  elif [ ! -f "$1" ]; then
    printf "File not found: %s\n" "$1" >&2
    return 1
  fi

  local name="${1%%.*}"
  local extension="${1#*.}"

  case "$extension" in
    lrz)     lrztar -d "$1" ;;
    tar.bz2) tar xjf "$1" ;;
    tar.gz)  tar xzf "$1" ;;
    tar.xz)  tar Jxf "$1" ;;
    bz2)     bunzip2 "$1" ;;
    gz)      gunzip "$1" ;;
    xz)      tar xvJf "$1" ;;
    tar)     tar xf "$1" ;;
    tbz2)    tar xjf "$1" ;;
    tgz)     tar xzf "$1" ;;
    zip|7z)  7z x "$1" ;;
    Z)       uncompress "$1" ;;
    rar)     unrar x "$1" ;;
    *)       printf "Unrecognized file extension: %s\n" "$extension" >&2
             return 1 ;;
  esac

  local ret=$?

  if [ "$ret" -eq "0" ] && [ -d "$name" ]; then
    cd "$name"
  fi

  return $ret
}

## enable color support of ls and also add handy aliases
#if [ -x /usr/bin/dircolors ]; then
#    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
#    #alias dir='dir --color=auto'
#    #alias vdir='vdir --color=auto'
#
#    #alias grep='grep --color=auto'
#    #alias fgrep='fgrep --color=auto'
#    #alias egrep='egrep --color=auto'
#fi
