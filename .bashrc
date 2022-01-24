if [[ -z "${EDITOR}" ]]; then
  . ~/.bash_profile
fi

case `uname -s` in 
  Linux*)  
    color='--color=auto'
    shopt -s direxpand
    ;;
  Darwin*) 
    alias ldd="otool -L"
    color='-G'
    ;;
  *)       
    echo Unknown Platform
    ;;
esac

alias ipython='python -m IPython'
alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'

if type exa &> /dev/null; then
  alias ll='exa -ls modified --time-style=iso'
  alias ls='exa'
else
  alias ls="ls -Fh ${color}"
  alias ll="ls -ltr"
fi

case ${HOSTNAME} in 
    (silver)
      stty -ixon
      source ${HOME}/py3/bin/activate
      ;;
    (black)
      stty -ixon
    	alias hd=hexyl
      ;;
    (*)
      ;;
esac

if [ -f ~/.aliases.sh ]; then
   source ~/.aliases.sh
fi

RED='\[\033[31m\]'
BRED="\[\033[1;31m\]"
YELLOW='\[\033[33;1m\]'
GREEN='\[\033[32m\]'
CYAN='\[\033[36m\]'
BLUE="\[\033[0;34m\]"
BPURPLE="\[\033[1;35m\]"
NC='\[\033[m\]'

if [ -n "${I3_BUILD}" ]; then
  export I3_VERSION=`grep Version ${I3_BUILD}/env-shell.sh | cut -d" " -f7`/`basename ${I3_BUILD}`
  I3TITLE="[${I3_VERSION}]"
  I3PROMPT="[${RED}${I3_VERSION}${NC}]"
  alias grep="grep --exclude-dir='.svn' --exclude=*.pyc --exclude=*~"
  alias makec="make -C${I3_BUILD}"
else
  I3TITLE=":"
  I3PROMPT="-${CYAN}\u${NC}@"
fi

prompt_command () {
  ERR="$(printf %02x $?)"
  if [ "${ERR}" = "00" ]; then # set an error string for the prompt, if applicable
    ERRPROMPT="${NC}${ERR}${NC}"
  else
    ERRPROMPT="${BRED}${ERR}${NC}"
  fi
  PYTHON_VERSION=`python -V 2> /dev/stdout| awk '{print $2}'`
  if [ "${PYTHON_VERSION:0:1}" -eq "2" ]; then
    PYPROMPT="${BPURPLE}${PYTHON_VERSION:0:1}${PYTHON_VERSION:2:1}${NC}"
  else
    PYPROMPT="${BLUE}${PYTHON_VERSION:0:1}${PYTHON_VERSION:2:1}${NC}"
  fi
  echo -en "\033]0;$(hostname -s) ${I3TITLE} ${PWD}\a"  
  export PS1="${ERRPROMPT}:${PYPROMPT}${I3PROMPT}${GREEN}\h${NC}:${YELLOW}\w${NC}$ "
}
PROMPT_COMMAND=prompt_command


# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
