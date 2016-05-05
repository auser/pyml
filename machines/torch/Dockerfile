FROM auser/tensorflow

# Based upon https://hub.docker.com/r/kaixhin/torch/~/dockerfile/
USER root
# Install Torch
# -------------
# including Lua, iTorch, loadcaffe, fblualib

ENV INSTALL_DIR "/usr/local/src"
ENV USER_DIR "/home/compute"

# Install git, apt-add-repository and dependencies for iTorch
RUN apt-get update && apt-get install -yq \
  git \
  software-properties-common \
  libssl-dev \
  libzmq3-dev \
  cmake \
  build-essential curl

# Install Jupyter Notebook for iTorch
RUN pip install ipython notebook ipywidgets

# [ Torch ]
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash -e && \
    git clone https://github.com/torch/distro.git $INSTALL_DIR/torch --recursive && \
    cd $INSTALL_DIR/torch && \
    ./install.sh && \
    $INSTALL_DIR/torch/install/bin/luarocks install nn && \
    $INSTALL_DIR/torch/install/bin/luarocks install dpnn && \
    $INSTALL_DIR/torch/install/bin/luarocks install image && \
    $INSTALL_DIR/torch/install/bin/luarocks install optim && \
    $INSTALL_DIR/torch/install/bin/luarocks install csvigo

ENV LD_LIBRARY_PATH /usr/local/lib:/opt/OpenBLAS/lib
ENV PATH $INSTALL_DIR/torch/install/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Export environment variables manually
ENV LUA_PATH='$INSTALL_DIR/.luarocks/share/lua/5.1/?.lua;$INSTALL_DIR/.luarocks/share/lua/5.1/?/init.lua;$INSTALL_DIR/torch/install/share/lua/5.1/?.lua;$INSTALL_DIR/torch/install/share/lua/5.1/?/init.lua;./?.lua;$INSTALL_DIR/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='$INSTALL_DIR/.luarocks/lib/lua/5.1/?.so;$INSTALL_DIR/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=$INSTALL_DIR/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=$INSTALL_DIR/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=$INSTALL_DIR/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='$INSTALL_DIR/torch/install/lib/?.so;'$LUA_CPATH

# RUN git clone https://github.com/facebook/iTorch.git $INSTALL_DIR/iTorch

# RUN cd $INSTALL_DIR/iTorch && env "PATH=$PATH" luarocks make
# RUN cd $INSTALL_DIR/iTorch && chown -R "$USER" "$(dirname $(ipython locate profile))"
# RUN cp -r $INSTALL_DIR/.ipython/* /usr/local/share/jupyter/

RUN env "PATH=$PATH" $INSTALL_DIR/torch/install/bin/luarocks install itorch
