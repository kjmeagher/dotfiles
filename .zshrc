# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'

case `uname -s` in
  Linux*)
    color='--color=auto'
    ;;
  Darwin*)
    alias ldd="otool -L"
    color='-G'
    stty -ixon
    ;;
  *)
    echo Unknown Platform
    ;;
esac

if type exa &> /dev/null; then
  alias ll='exa -ls modified --time-style=iso'
  alias ls='exa'
else
  alias ls="ls -Fh ${color}"
  alias ll="ls -ltr"
fi

if (( $+commands[hexyl] )); then
  alias hd='hexyl --border none'
fi

zstyle :compinstall filename '/Users/kmeagher/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall



PYTHON_VERSION=`python3 -c "v=__import__('sys').version_info;print('%d%02d'%(v.major,v.minor))"`

if [[ -n "${I3_BUILD}" ]]; then
	export I3_VERSION=`grep Version ${I3_BUILD}/env-shell.sh | cut -d" " -f7`/`basename ${I3_BUILD}`
	I3PROMPT="[%F{red}${I3_VERSION}%f]"
else
	I3PROMPT="-%F{cyan}%n$f@"
fi

# echo %(?..[%?] )x`
setopt PROMPT_SUBST
PROMPT='%(?..%F{red})$(printf %02x $?)%f:%F{blue}${PYTHON_VERSION}%f${I3PROMPT}%F{green}%m%f:%F{yellow}%~%f%# '
