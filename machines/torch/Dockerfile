FROM auser/tensorflow

# Based upon https://hub.docker.com/r/kaixhin/torch/~/dockerfile/
USER root
# Install Torch
# -------------
# including Lua, iTorch, loadcaffe, fblualib

# Install git, apt-add-repository and dependencies for iTorch
RUN apt-get update && apt-get install -y \
  git \
  software-properties-common \
  libssl-dev \
  libzmq3-dev

# Install Jupyter Notebook for iTorch
RUN pip install ipython notebook ipywidgets

# Run Torch7 installation scripts
RUN git clone https://github.com/torch/distro.git /root/torch --recursive && cd /root/torch
RUN git clone --depth 1 https://github.com/geco/ezinstall.git /tmp/torch_install
RUN cd /tmp/torch_install && \
    bash install-deps

RUN echo $DISTRO && \
    . /etc/os-release && \
    python -c "import platform;print(platform.linux_distribution()[0])"

RUN cd /root/torch && \
  ./install.sh

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

# RUN git clone https://github.com/facebook/iTorch.git /root/iTorch

# RUN ls /root/torch/install/bin
# RUN cd /root/iTorch && env "PATH=$PATH" luarocks make
# RUN cd /root/iTorch && chown -R "$USER" "$(dirname $(ipython locate profile))"
# RUN cp -r /root/.ipython/* /usr/local/share/jupyter/

RUN env "PATH=$PATH" luarocks install itorch
RUN chown -R $NB_USER $(dirname $(ipython locate profile))

# Set ~/torch as working directory
WORKDIR /root/torch
