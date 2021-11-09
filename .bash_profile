export EDITOR="micro"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PYTHONPATH=${HOME}/.local/lib/python
export PATH=${HOME}/.local/bin:${PATH}
export SVN=http://code.icecube.wisc.edu/svn
export HISTSIZE=100000

case ${HOSTNAME} in 
    silver)
      export EDITOR="/usr/local/bin/micro"
      export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
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
    export TMPDIR=/scratch/kmeagher/scratch
    export _CONDOR_SCRATCH_DIR=$TMPDIR
    ;;
  black)
    export I3_DATA=${HOME}/s1/icecube/data
    export I3_TESTDATA=${I3_DATA}/i3-test-data-svn/trunk
    export TERMINAL=/usr/bin/kitty
    export LD_LIBRARY_PATH=/usr/local/lib
    export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.9/site-packages
    export G4LEVELGAMMADATA=/usr/share/geant4-levelgammadata/PhotonEvaporation5.7
    export G4ENSDFSTATEDATA=/usr/share/geant4-ensdfstatedata/G4ENSDFSTATE2.3
    export G4LEDATA=/usr/share/geant4-ledata/G4EMLOW7.13/
    export G4PARTICLEXSDATA=/usr/share/geant4-particlexsdata/G4PARTICLEXS3.1
    ;;
  *)
    echo "Unknown hostname ${HOSTNAME}"
    ;;
esac

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
