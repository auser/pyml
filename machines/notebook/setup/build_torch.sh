#!/bin/bash

INSTALL_DIR=${INSTALL_DIR:-"/usr/local/src"}
USER_DIR=${USER_DIR:-"/home/compute"}

# Install git, apt-add-repository and dependencies for iTorch
apt-get update && apt-get install -yq \
  git \
  software-properties-common \
  libssl-dev \
  libzmq3-dev

# Install Jupyter Notebook for iTorch
pip install ipython notebook ipywidgets

# [ Torch ]
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash -e && \
    git clone https://github.com/torch/distro.git $INSTALL_DIR/torch --recursive && \
    cd $INSTALL_DIR/torch && \
    ./install.sh && \
    $INSTALL_DIR/torch/install/bin/luarocks install nn && \
    $INSTALL_DIR/torch/install/bin/luarocks install dpnn && \
    $INSTALL_DIR/torch/install/bin/luarocks install image && \
    $INSTALL_DIR/torch/install/bin/luarocks install optim && \
    $INSTALL_DIR/torch/install/bin/luarocks install csvigo

LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-/usr/local/lib:/opt/OpenBLAS/lib}
export PATH=$INSTALL_DIR/torch/install/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# Export environment variables manually
export LUA_PATH='$INSTALL_DIR/.luarocks/share/lua/5.1/?.lua;$INSTALL_DIR/.luarocks/share/lua/5.1/?/init.lua;$INSTALL_DIR/torch/install/share/lua/5.1/?.lua;$INSTALL_DIR/torch/install/share/lua/5.1/?/init.lua;./?.lua;$INSTALL_DIR/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
export LUA_CPATH='$INSTALL_DIR/.luarocks/lib/lua/5.1/?.so;$INSTALL_DIR/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
export PATH=$INSTALL_DIR/torch/install/bin:$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/torch/install/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$INSTALL_DIR/torch/install/lib:$DYLD_LIBRARY_PATH
export LUA_CPATH='$INSTALL_DIR/torch/install/lib/?.so;'$LUA_CPATH

env "PATH=$PATH" luarocks install itorch
