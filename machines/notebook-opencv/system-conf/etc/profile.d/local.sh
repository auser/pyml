# Add ~/.local directory to system paths
export PATH="${HOME}/.local/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/.local/lib:${LD_LIBRARY_PATH}:/usr/local/cuda/lib:/usr/local/cuda/lib64"

# Add CUDA
export PATH="$PATH:/usr/local/cuda/bin"

echo "Liftoff!"

export LOCAL_PROFILE_SETUP="true"
