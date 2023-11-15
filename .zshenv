#macos loads this file for every gui program so we need to put all the variables
#needed in codium here. It doesn't load the other .zsh files except in the terminal

FPATH=${HOME}/.config/zfunc:$FPATH

if [ -x '/opt/homebrew/bin/brew' ]; then
  brew=/opt/homebrew/bin/brew
elif [ -x '/usr/local/bin/brew' ]; then
  brew=/usr/local/bin/brew
fi
 
if [[ -n "${brew+1}" ]]; then
  eval $(${brew} shellenv)
  export PATH=$(brew --prefix python@3.12)/libexec/bin:${PATH}
  export HDF5_DIR=$(brew --prefix hdf5)
  export SROOT=$(brew --prefix)
  export PKG_CONFIG_PATH=$(brew --prefix libarchive)/lib/pkgconfig/:$(brew --prefix openblas)/lib/pkgconfig/
fi
 
case ${HOST} in
  KevinsLaptop)
  	export I3_TESTDATA=${HOME}/icecube/test-data/trunk
    ;;
esac
