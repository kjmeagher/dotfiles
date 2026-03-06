
if not set -q EXPORTS_SET
  set -x EXPORTS_SET 1
  
  switch $hostname
    case black
      set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
      set -x TERMINAL /usr/bin/kitty
      set -xp LD_LIBRARY_PATH /usr/local/lib
    case n-gpu-42.icecube.wisc.edu
      set -x XDG_CACHE_HOME /scratch/local/ice3simusr/.cache
  end

  switch (uname)
    case Darwin
      set -x XDG_DATA_HOME $HOME/.local/share
      set -x XDG_CONFIG_HOME $HOME/.config
      set -x XDG_STATE_HOME $HOME/.local/state
      set -x XDG_CACHE_HOME $HOME/.cache
    case Linux
    case '*'
      echo Unknown Platform
  end

  if set -q SROOT
    set -x BOOST_ROOT $SROOT
  end

  set -x CLICOLOR 1
  set -x LSCOLORS ExFxBxDxCxegedabagacad
  set -x LESS '-R'
  set -x BETTER_EXCEPTIONS 1

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
  if not set -q _CONDOR_SCRATCH_DIR
    if [ -d /scratch/kmeagher/scratch ]
        set -x _CONDOR_SCRATCH_DIR /scratch/kmeagher/scratch
    end
  end

  set -l nv_dir /data/user/kmeagher/opt/nvidia/Linux_x86_64/24.5
  if [ -d $nv_dir ]
    set -xp PATH $nv_dir/compilers/bin/
    set -xp MANPATH $nv_dir/25.3/compilers/man
  end

  if command -q brew
    set -x HOMEBREW_PREFIX (brew --prefix)
    set -x HOMEBREW_CELLAR (brew --cellar)
    set -x HOMEBREW_REPOSITORY (brew --repo)
    set -x UV_PYTHON 3.14
    set -x HDF5_DIR (brew --prefix hdf5)
    set -xp PKG_CONFIG_PATH (brew --prefix libarchive)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix openblas)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix ncurses)/lib/pkgconfig/
    set -xp PKG_CONFIG_PATH (brew --prefix qt@5)/lib/pkgconfig/
  end
   if command -q micro
     set -x EDITOR micro
   else if command -q nano
     set -x EDITOR nano
   end
end # EXPORTS_SET

if status is-interactive
  switch (uname)
    case Darwin
      alias ldd="otool -L"
      set color '-G'
    case Linux
      set color '--color=auto'
    case '*'
      echo Unknown Platform
  end

  alias dfs='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

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

  if command -q uv
    uv generate-shell-completion fish | source
  end
  if command -q uvx
    uvx --generate-shell-completion fish | source
  end
  
end # is-interactive
   
if set -q UV_PYTHON
  set _pyver (echo $UV_PYTHON | tr -d '.')
else
  set _pyver (python3 -c v="__import__('sys').version_info;print('%d%d'%(v.major,v.minor))")
end

if set -q I3_BUILD
  set _i3pyexe (string split '=' -f2 (grep PYTHON_EXECUTABLE $I3_BUILD/CMakeCache.txt))  
  if test -e (dirname $_i3pyexe)/activate.fish
    echo Found venv from CMakeCache.txt
    set _venvdir (dirname (dirname $_i3pyexe))
  else if test -d $HOME/.venvs/icetray-py$_pyver
    echo Using central IceTray venv
    set _venvdir $HOME/.venvs/icetray-py$_pyver
  else
    echo "Cant find venv dir for icetray with python $_pyver and $_i3pyexe"
  end
else 
  if set -q VIRTUAL_ENV
    echo sticking with VIRTUAL_ENV: $VIRTUAL_ENV
  else if test -e $PWD/.venv/bin/activate.fish
    set _venvdir $PWD/.venv
  else if test -e $HOME/.venvs/py$pyver/bin/activate.fish
    set _venvdir $HOME/.venvs/py$_pyver
  else
    echo No Suitable venv found
  end
end

if set -q _venvdir
  echo Sourceing venv: $_venvdir/bin/activate.fish
  source $_venvdir/bin/activate.fish
end

if set -q I3_BUILD
  set -xp PATH $I3_BUILD/bin
end
  
if test -n $MANPATH[1]
  set -xp MANPATH ""
end
