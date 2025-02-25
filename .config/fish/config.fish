switch $hostname
  case black
    set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    set -x TERMINAL /usr/bin/kitty
    set -xp LD_LIBRARY_PATH /usr/local/lib
end

if set -q SROOT
    set -x BOOST_ROOT $SROOT
end

if status is-interactive

  set -x CLICOLOR 1
  set -x LSCOLORS ExFxBxDxCxegedabagacad
  set -x LESS '-R'
  set -x BETTER_EXCEPTIONS 1

  alias dfs='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
  alias pytest='python -m pytest'

  if [ -d $HOME/.kjm/bin ]
    set -xp PATH $HOME/.kjm/bin
  end
  if [ -d $HOME/.kjm/share/man ] 
    if not contains $HOME/.kjm/share/man $MANPATH
      set -xp MANPATH $HOME/.kjm/share/man
    end
  end
  if [ -d /data/user/kmeagher/.cargo ]
    set -x RUSTUP_HOME /data/user/kmeagher/.rustup
    set -x CARGO_HOME /data/user/kmeagher/.cargo
    set -xp PATH $CARGO_HOME/bin
  end
  if [ -d $HOME/icecube/test-data/trunk ]
    set -x I3_TESTDATA $HOME/icecube/test-data/trunk
  else if [ -d /mnt/s2/icecube/data/test-data/trunk/ ]
    set -x I3_TESTDATA /mnt/s2/icecube/data/test-data/trunk/
  end
  if [ -d /scratch/kmeagher/scratch ]
    set -x _CONDOR_SCRATCH_DIR /scratch/kmeagher/scratch
  end

  if [ -d /data/user/kmeagher/opt/nvidia/Linux_x86_64/2024/compilers/bin/ ]
    fish_add_path -P /data/user/kmeagher/opt/nvidia/Linux_x86_64/2024/compilers/bin/
  end

  switch (uname)
    case Darwin
      alias ldd="otool -L"
      set color '-G'
    case Linux
      set color '--color=auto'
    case '*'
      echo Unknown Platform
  end

  if command -q /opt/homebrew/bin/brew
    set -f brew /opt/homebrew/bin/brew
  else if command -q /usr/local/bin/brew
    set brew /usr/local/bin/brew
  end

  if set -q brew
    eval ($brew shellenv)
    set -x UV_PYTHON 3.13
    set pyver '313'
    set -x HDF5_DIR (brew --prefix hdf5)
    set -xp PKG_CONFIG_PATH (brew --prefix libarchive)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix openblas)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix ncurses)/lib/pkgconfig/
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

  if command -q codium
    set CODE codium
  else if command -q /Applications/VSCodium.app/Contents/Resources/app/bin/codium
    set CODE /Applications/VSCodium.app/Contents/Resources/app/bin/codium
  end
  if string match -q "$TERM_PROGRAM" "vscode"
    . ($CODE --locate-shell-integration-path fish)
    set -x EDITOR $CODE --wait
  end

  if not set -q pyver
    set pyver (python -c v="__import__('sys').version_info;print('%d%d'%(v.major,v.minor))")
  end
  if set -q I3_BUILD
    if test -d $I3_BUILD/../venv$pyver
        set venvdir $I3_BUILD/../venv$pyver
    else if test -d $HOME/.venvs/icetray-py$pyver
        set venvdir $HOME/.venvs/icetray-py$pyver
    else
        echo "Cant find venv dir for icetray with python $pyver"
    end
  else
    set venvdir $HOME/.venvs/py$pyver
  end

  source $venvdir/bin/activate.fish

  if set -q I3_BUILD
    set -xp PATH $I3_BUILD/bin
  end

  if test -n $MANPATH[1]
    set -xp MANPATH ""
  end

  if command -q uv
    uv generate-shell-completion fish | source
  end
  if command -q uvx
    uvx --generate-shell-completion fish | source
  end
  
end
