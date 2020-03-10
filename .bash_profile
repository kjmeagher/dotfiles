export GREP_OPTIONS='--exclude-dir=.svn'
export EDITOR="nano"
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LC_ALL=en_US.UTF-8
export HOMEBREW_NO_INSTALL_CLEANUP=1


export PATH="${HOME}/.local/bin:${HOME}/Library/Python/2.7/bin/:/usr/local/opt/qt5/bin/:${PATH}"
export PYTHONPATH=/Users/kmeagher/.local/lib

#export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
#export I3_TESTDATA=${I3_DATA}/i3-test-data/
export I3_TESTDATA=/Users/kmeagher/icecube/testdata/trunk/
export SVN=http://code.icecube.wisc.edu/svn
export PKG_CONFIG_PATH=/usr/local/opt/libarchive/lib/pkgconfig/:/usr/local/opt/openblas/lib/pkgconfig/

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

HOMEBREW_PREFIX=$(brew --prefix)
if type brew &>/dev/null; then
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi
fi

#source ${HOME}/py3/bin/activate



