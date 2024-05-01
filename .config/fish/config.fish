set -x CLICOLOR 1
set -x LSCOLORS ExFxBxDxCxegedabagacad
set -x LESS '-R'
set -x BETTER_EXCEPTIONS 1

switch $hostname 
  case 'cobalt*'
    set -x I3_DATA /cvmfs/icecube.opensciencegrid.org/data/
    set -x TMPDIR /scratch/kmeagher/scratch
    set -x _CONDOR_SCRATCH_DIR $TMPDIR
    set -x RUSTUP_HOME=/data/user/kmeagher/.rustup
    set -x CARGO_HOME=/data/user/kmeagher/.cargo
    fish_add_path $CARGO_HOME/bin
    set -xp MANPATH=$HOME/.kjm/share/man
  case black
    set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    set -x TERMINAL /usr/bin/kitty
    set -x I3_DATA $HOME/s1/icecube/data
    set -x I3_TESTDATA $I3_DATA/i3-test-data-svn/trunk
    set -xp LD_LIBRARY_PATH /usr/local/lib
    # export PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.9/compilers/bin:${PATH}
    # export PATH=$PATH:/opt/cuda/bin
  case KevinsLaptop
    export I3_TESTDATA=$HOME/icecube/test-data/trunk
end

if status is-interactive

  fish_add_path $HOME/.kjm/bin
  alias dfs='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
  alias pytest='python -m pytest'
  

  switch (uname)
    case Darwin
      alias ldd="otool -L"
      set color '-G'
    case Linux
      set color '--color=auto'
    case '*'
      echo Unknown Platform
  end

  if command -q /Applications/VSCodium.app/Contents/Resources/app/bin/codium
    alias code=/Applications/VSCodium.app/Contents/Resources/app/bin/codium
  end
  if string match -q "$TERM_PROGRAM" "vscode"
    . (code --locate-shell-integration-path fish)
  end

  if command -q /opt/homebrew/bin/brew
    set -f brew /opt/homebrew/bin/brew
  else if command -q /usr/local/bin/brew
    set brew /usr/local/bin/brew
  end

  if set -q brew
    eval ($brew shellenv)
    fish_add_path (brew --prefix python@3.12)/libexec/bin
    set -x HDF5_DIR (brew --prefix hdf5)
    set -xp PKG_CONFIG_PATH (brew --prefix libarchive)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix openblas)/lib/pkgconfig/
  end

  if command -q micro
    set -x EDITOR micro
  else if coommand -q nano
    set -x EDITOR nano
  end

  if command -q eza
    alias ll='eza -ls modified --time-style=iso'
    alias ls='eza'
  else
    alias ls="ls -Fh $color"
    alias ll="ls -ltr"
  end
  
  if command -q hexyl
    alias hd='hexyl --border none'
  end

  set pyver (python -c v="__import__('sys').version_info;print('%d%d'%(v.major,v.minor))")
  if set -q I3_BUILD
    set venvdir $I3_BUILD/../venv$pyver
  else
    set venvdir $HOME/.venvs/py$pyver
  end

  if set -q venvdir
    source $venvdir/bin/activate.fish
  end
end

