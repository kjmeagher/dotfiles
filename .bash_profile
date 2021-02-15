export EDITOR="emacs -nw"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PYTHONPATH=${HOME}/.local/lib/python
export PATH=${HOME}/.local/bin:${PATH}
export SVN=http://code.icecube.wisc.edu/svn

case ${HOSTNAME} in 
    silver)
      export I3_TESTDATA=/Users/kmeagher/icecube/testdata/trunk/
      export SROOT=/usr/local/
      export PKG_CONFIG_PATH=/usr/local/opt/libarchive/lib/pkgconfig/:/usr/local/opt/openblas/lib/pkgconfig/
      export HOMEBREW_NO_INSTALL_CLEANUP=1
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
      ;;
  cobalt*)
    export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
    export I3_TESTDATA=${I3_DATA}/i3-test-data-svn/trunk
    export TMPDIR=/scratch/kmeagher/scratch
    export _CONDOR_SCRATCH_DIR=$TMPDIR
    ;;
  black)
    #export SROOT=/usr/local
    export I3_TESTDATA=${HOME}/s1/icecube/i3-test-data/trunk
    export TERMINAL=/usr/bin/termite
    ;;
  *)
    echo "Unknown hostname ${HOSTNAME}"
    ;;
esac

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
