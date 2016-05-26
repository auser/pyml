#!/bin/bash

USER_UID=${USER_UID:-1001}
USER_LOGIN=${USER:-jovyan}
USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
USER_DIR="/home/${USER_LOGIN}"
PASSWORD=${PASSWORD:-itsginger}
PYTHON_ENV=${PYTHON_ENV:-py2}

NOTEBOOK_PORT=${PORT:-8888}

JDIR="${USER_DIR}/.jupyter"
CONF_FILE="${JDIR}/jupyter_notebook_config.py"
NOTEBOOK_DIR="${USER_DIR}/notebooks"
PASSWORD_FILE=${JDIR}/.pass

LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/include:/usr/local/lib:/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/lib/nvidia-352

##### Working stuff
echo "Creating user ${USER_LOGIN} (${USER_UID}:${USER_GID})..."
if [[ ! $(id -u $USER_LOGIN &>/dev/null) ]]; then
  useradd --home "${USER_DIR}" \
          --shell "/bin/bash" \
          --create-home \
          --uid ${USER_UID} \
          "${USER_LOGIN}" >/dev/null
fi

mkdir -p -m 700 ${USER_DIR}
mkdir -p -m 700 ${JDIR}/security
mkdir -p -m 700 ${NOTEBOOK_DIR}

# adduser "${USER_LOGIN}" compute-users

chown -R $USER_LOGIN $USER_DIR
IPY_DIR=$(ipython locate)

## Create the config
# SSL cert
# openssl req -new -newkey rsa:2048 -days 2652 -nodes -x509 -subj "//CN=ipython.ari.io" -keyout ${JDIR}/security/ssl_${USER_LOGIN}.pem -out ${JDIR}/security/ssl_${USER_LOGIN}.pem

echo $PASSWORD > $PASSWORD_FILE

cat<<EOF | tee ${CONF_FILE}
import os
import sys

os.environ['SHELL'] = '/bin/bash'
os.environ['PYTHONPATH'] = '$PYTHONPATH:$NOTEBOOK_DIR'

# Configure the environment
os.environ['SPARK_HOME'] = '${SPARK_HOME}'

# Create a variable for our root path
SPARK_HOME = os.environ['SPARK_HOME']

# Add the PySpark/py4j to the Python Path
# sys.path.insert(0, os.path.join(SPARK_HOME, "python", "lib"))
# sys.path.insert(0, os.path.join(SPARK_HOME, "python", "pyspark"))
# sys.path.insert(0, os.path.join(SPARK_HOME, "python"))

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = ${NOTEBOOK_PORT}
c.NotebookApp.port_retries = 249
c.NotebookApp.enable_mathjax = True
c.NotebookApp.open_browser = False
# c.NotebookApp.certfile = u'${JDIR}/security/ssl_${USER_LOGIN}.pem'

from IPython.lib import passwd
with open('${PASSWORD_FILE}', 'r') as fp:
    p = fp.read().strip()
c.NotebookApp.password = passwd(p)

## Include the normal things
c.InteractiveShellApp.exec_lines = [
  '%matplotlib inline',
  '%load_ext autoreload',
  '%autoreload 2',
]

c.InteractiveShell.autoindent = True
c.InteractiveShell.colors = 'LightBG'
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True
c.InteractiveShell.editor = 'nano'
c.InteractiveShell.xmode = 'Context'

c.InteractiveShellApp.matplotlib = 'inline'
c.NotebookApp.notebook_dir = os.path.expanduser('${NOTEBOOK_DIR}')
EOF

# chown -R $USER_LOGIN $(dirname $(ipython locate profile))

# jupyter
SUDO="sudo"
HOME="${USER_DIR}" LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" $SUDO -E -u "${USER_LOGIN}" ${CMD:-/bin/bash --login -c "jupyter notebook --config=${CONF_FILE} --ip='*' --no-browser > ${USER_DIR}/jupyter.log 2>&1"}
# HOME="${USER_DIR}" /bin/bash --login -c "jupyter notebook --config=${CONF_FILE} --ip='*' --no-browser > jupyter.log 2>&1"
