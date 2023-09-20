# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

stty -ixon
alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'

if (( $+commands[brew] )); then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
fi

autoload -Uz compinit
compinit
autoload -Uz python_version

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
else
	I3PROMPT="-%F{cyan}%n$f@"
fi
setopt PROMPT_SUBST
PROMPT='%(?..%F{red})$(printf %02x $?)%f:$(python_version)${I3PROMPT}%F{green}%m%f:%F{yellow}%~%f%# '

#shell integeration for codium
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(codium --locate-shell-integration-path zsh)"
