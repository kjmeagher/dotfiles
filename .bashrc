alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'
alias ls='ls -Fh --color=auto'
alias ll="ls -ltr"
alias grep='grep --color=auto --exclude-dir=.svn'
alias vi='vim'

if [[ ${HOSTNAME} =~ ^cobalt.* ]]; then
    alias emacs=emacs-24.3-nox
    shopt -s direxpand
fi

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
  I3PROMPT="[${RED}${I3_VERSION}${NC}]"
  alias grep="grep --exclude-dir='.svn' --exclude=*.pyc --exclude=*~"
  alias make="make -C${I3_BUILD} -j32"
  alias ninja="ninja -C${I3_BUILD}"
  alias wipe_cache="rm -v ${I3_BUILD}/CMakeCache.txt && i3cmake"
else
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
  export PS1="${ERRPROMPT}:${PYPROMPT}${I3PROMPT}${GREEN}\h${NC}:${YELLOW}\w${NC}$ "
}
PROMPT_COMMAND=prompt_command
