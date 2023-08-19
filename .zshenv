#macos loads this file for every gui program so we need to put all the variables
#needed in codium here. It doesn't load the other .zsh files except in the terminal

if [ -x '/opt/homebrew/bin/brew' ]; then
  export PATH='/opt/homebrew/bin':${PATH}
elif [ -x '/usr/local/bin/brew' ]; then
  path+='/usr/local/bin'
fi

if (( $+commands[brew] )); then
  export PATH=$(brew --prefix python)/libexec/bin:${PATH}
  export HDF5_DIR=$(brew --prefix hdf5)
  export SROOT=$(brew --prefix)
  export PKG_CONFIG_PATH=$(brew --prefix libarchive)/lib/pkgconfig/:$(brew --prefix openblas)/lib/pkgconfig/
fi

case ${HOST} in
  KevinsLaptop)
   	export I3_TESTDATA=${HOME}/icecube/test-data/trunk
    ;;
  cobalt*)
    export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
    export TMPDIR=/scratch/kmeagher/scratch
    export _CONDOR_SCRATCH_DIR=$TMPDIR
    export RUSTUP_HOME=/data/user/kmeagher/.rustup
    export CARGO_HOME=/data/user/kmeagher/.cargo
    export PATH=${CARGO_HOME}/bin:${PATH}
    ;;
  black)
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    export I3_DATA=${HOME}/s1/icecube/data
    export I3_TESTDATA=${I3_DATA}/i3-test-data-svn/trunk
    export LD_LIBRARY_PATH=/usr/local/lib
    # export G4LEVELGAMMADATA=/usr/share/geant4-levelgammadata/PhotonEvaporation5.7
    # export G4ENSDFSTATEDATA=/usr/share/geant4-ensdfstatedata/G4ENSDFSTATE2.3
    # export G4LEDATA=/usr/share/geant4-ledata/G4EMLOW7.13/
    # export G4PARTICLEXSDATA=/usr/share/geant4-particlexsdata/G4PARTICLEXS3.1
    if [ -d "/opt/cuda/bin" ]; then
        export PATH=$PATH:/opt/cuda/bin
    fi
    ;;
esac
