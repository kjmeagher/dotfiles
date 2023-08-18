#add brew to the begining of the path after macos addes system paths over what
#was added in .zshenv
if (( $+commands[brew] )); then
  export PATH=$(brew --prefix)/bin:${PATH}
fi

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LESS='-R'
export BETTER_EXCEPTIONS=1

if (( $+commands[micro] )); then
  export EDITOR="micro"
else
  export EDITOR="nano"
fi
