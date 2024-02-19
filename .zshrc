export SRUN="zshrc:${SRUN}"
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
alias pytest='python -m pytest'

#shell integeration for codium
codium=/Applications/VSCodium.app/Contents/Resources/app/bin/codium
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(${codium} --locate-shell-integration-path zsh)"
 
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

if [ -x '/opt/homebrew/bin/brew' ]; then
  brew=/opt/homebrew/bin/brew
elif [ -x '/usr/local/bin/brew' ]; then
  brew=/usr/local/bin/brew
fi
 
if [[ -n "${brew+1}" ]]; then
  eval $(${brew} shellenv)
  export PATH=$(brew --prefix python@3.12)/libexec/bin:${PATH}
  export HDF5_DIR=$(brew --prefix hdf5)
  # export SROOT=$(brew --prefix)
  export PKG_CONFIG_PATH=$(brew --prefix libarchive)/lib/pkgconfig/:$(brew --prefix openblas)/lib/pkgconfig/
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

if (( $+commands[micro] )); then
  export EDITOR="micro"
else
  export EDITOR="nano"
fi

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

FPATH=${HOME}/.config/zfunc:$FPATH
autoload -Uz compinit
compinit
autoload -Uz python_version
compinit -d "${HOME}"/.cache/zsh/zcompdump-"$ZSH_VERSION"


pyver=$(python -c v="__import__('sys').version_info;print('%d%d'%(v.major,v.minor))")
if [[ -n "${I3_BUILD}" ]]; then
	export I3_VERSION=`grep Version ${I3_BUILD}/env-shell.sh | cut -d" " -f7`/`basename ${I3_BUILD}`
	I3PROMPT="[%F{red}${I3_VERSION}%f]"
	export PATH=$(echo $PATH | tr ":" "\n" | grep -v '\.local' | xargs | tr ' ' ':')
	if [[ ${I3_BUILD} == /cvmfs/* ]]; then
		venvdir=${HOME}/.venvs/ic${pyver}
	else
		venvdir=${I3_BUILD}/../venv${pyver}
	fi
else
	I3PROMPT="-%F{cyan}%n$f@"
	if [[ -n "${VSCODE_PID}" ]]; then
	else
		venvdir=${HOME}/.venvs/py${pyver}
	fi
fi
# if [ -d "${venvdir}" ]; then
	source ${venvdir}/bin/activate
# fi
if [ ! -z "${VIRTUAL_ENV}" ]; then
	echo "VIRTUAL_ENV ${VIRTUAL_ENV}"
fi

setopt PROMPT_SUBST
PS1='%(?..%F{red})$(printf %02x $?)%f:$(python_version)${I3PROMPT}%F{green}%m%f:%F{yellow}%~%f%# '

if [ ! -z "${SROOT}" ]; then
	echo "SROOT: ${SROOT}"
fi
