export SRUN="zprofile:${SRUN}"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LESS='-R'
export BETTER_EXCEPTIONS=1
export PATH=${HOME}/.kjm/bin:${PATH}
export HISTFILE=.zsh_history
 
case ${HOST} in
  cobalt*)
    export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
    export TMPDIR=/scratch/kmeagher/scratch
    export _CONDOR_SCRATCH_DIR=$TMPDIR
    export RUSTUP_HOME=/data/user/kmeagher/.rustup
    export CARGO_HOME=/data/user/kmeagher/.cargo
    export PATH=${CARGO_HOME}/bin:${PATH}
    export MANPATH=${HOME}/.local/share/man:${MANPATH}
    ;;
  black)
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    export TERMINAL=/usr/bin/kitty
    export I3_DATA=${HOME}/s1/icecube/data
    export I3_TESTDATA=${I3_DATA}/i3-test-data-svn/trunk
    export LD_LIBRARY_PATH=/usr/local/lib
    export PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.9/compilers/bin:${PATH}
    # export G4LEVELGAMMADATA=/usr/share/geant4-levelgammadata/PhotonEvaporation5.7
    # export G4ENSDFSTATEDATA=/usr/share/geant4-ensdfstatedata/G4ENSDFSTATE2.3
    # export G4LEDATA=/usr/share/geant4-ledata/G4EMLOW7.13/
    # export G4PARTICLEXSDATA=/usr/share/geant4-particlexsdata/G4PARTICLEXS3.1
    # if [ -d "/opt/cuda/bin" ]; then
    #     export PATH=$PATH:/opt/cuda/bin
    # fi
    ;;
  KevinsLaptop)
    export I3_TESTDATA=${HOME}/icecube/test-data/trunk
  	;;
esac
