export EDITOR="vim"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

export PATH=${HOME}/.local/bin:${PATH}
#export PYTHONPATH=/Users/kmeagher/.local/lib

export SVN=http://code.icecube.wisc.edu/svn

if [[ ${HOSTNAME} =~ ^cobalt.* ]]; then
  export I3_DATA=/cvmfs/icecube.opensciencegrid.org/data/
  export I3_TESTDATA=${I3_DATA}/i3-test-data-svn/trunk
  export TMPDIR=/scratch/kmeagher/scratch
  export _CONDOR_SCRATCH_DIR=$TMPDIR
elif [[ ${HOSTNAME} == black ]]; then
  #export SROOT=/usr/local
  export I3_TESTDATA=${HOME}/s1/icecube/i3-test-data/trunk
fi 

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
