# Add ~/.local directory to system paths
export PATH="${HOME}/.local/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/.local/lib:/usr/lib/x86_64-linux-gnu:/usr/include:/usr/local/lib:/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/lib/nvidia-352:/usr/include/x86_64-linux-gnu:/usr/include/x86_64-linux-gnu"
# Add CUDA
export PATH="$PATH:/usr/local/cuda/bin"

export LOCAL_PROFILE_SETUP="true"
