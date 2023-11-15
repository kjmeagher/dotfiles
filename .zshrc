
# Lines configured by zsh-newuser-install
HISTSIZE=100000
SAVEHIST=100
bindkey -e
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

stty -ixon
alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'
 
#shell integeration for codium
codium=/Applications/VSCodium.app/Contents/Resources/app/bin/codium
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(${codium} --locate-shell-integration-path zsh)"
 
autoload -Uz compinit
compinit
autoload -Uz python_version
compinit -d "${HOME}"/.cache/zsh/zcompdump-"$ZSH_VERSION"

case `uname -s` in
  Linux*)
    color='--color=auto'
    ;;
  Darwin*)
    alias ldd="otool -L"
    color='-G'
    ;;
  *)
    echo Unknown Platform
    ;;
esac

if (( $+commands[eza] )); then
  alias ll='eza -ls modified --time-style=iso'
  alias ls='eza'
else
  alias ls="ls -Fh ${color}"
  alias ll="ls -ltr"
fi

if (( $+commands[hexyl] )); then
  alias hd='hexyl --border none'
fi

if [ -f ~/.aliases.sh ]; then
   source ~/.aliases.sh
fi
 
if [[ -n "${I3_BUILD}" ]]; then
	export I3_VERSION=`grep Version ${I3_BUILD}/env-shell.sh | cut -d" " -f7`/`basename ${I3_BUILD}`
	I3PROMPT="[%F{red}${I3_VERSION}%f]"
	export PATH=$(echo $PATH | tr ":" "\n" | grep -v '\.local' | xargs | tr ' ' ':')
	
	source ${I3_BUILD}/../venv/bin/activate
else
	I3PROMPT="-%F{cyan}%n$f@"
	source ${HOME}/.local/bin/activate
fi
setopt PROMPT_SUBST
PROMPT='%(?..%F{red})$(printf %02x $?)%f:$(python_version)${I3PROMPT}%F{green}%m%f:%F{yellow}%~%f%# '
