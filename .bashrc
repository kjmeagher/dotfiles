alias ls='ls -GFh'
alias ll="ls -ltrh"
alias ldd="otool -L"
alias svndi='for foo in * ; do svn di $foo; done'
alias mntv0='sshfs kjm@black:/mnt/storage/home/quasar/video/ ~/v0; open ~/v0'
alias mntv1='sshfs kjm@black:/mnt/s1/kjm/Videos ~/v1; open ~/v1'

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
 alias make="make -C${I3_BUILD} -j8"
 alias ninja='ninja -C${I3_BUILD}'
 alias wipe_cache="rm -v ${I3_BUILD}/CMakeCache.txt && i3cmake"
else
 echo
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
