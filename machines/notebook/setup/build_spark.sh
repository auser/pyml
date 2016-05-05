#!/bin/bash

SPARK_VERSION=${SPARK_VERSION:-"1.6.1"}
SPARK_HOME=${SPARK_HOME:-"/usr/local/spark"}

SCALA_VERSION=${SCALA_VERSION:-2.11.7}
SBT_VERSION=${SBT_VERSION:-0.13.11}

SBT_HOME=/usr/local/sbt
export PATH=${SBT_HOME}/bin:$PATH

# [ Spark ]
# Spark dependencies

## Java
apt-get update -yq
apt-get install -yq curl python-software-properties software-properties-common
# echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
# Install Java.
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

export JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Scala
# wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
# dpkg -i scala-2.11.8.deb

# Install Scala
## Piping curl directly in tar
\
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

# Install Python 3 packages
conda install --quiet --yes \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

conda install --quiet --yes \
    -p $CONDA_DIR/envs/python2 \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

## Py4J
cd /usr/local
# ## Spark
curl -sL -o "/usr/local/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"

tar xvf "spark-$SPARK_VERSION.tgz" && \
    mv "/usr/local/spark-$SPARK_VERSION" "$SPARK_HOME"

MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

cd "$SPARK_HOME" && \
    build/mvn -Pyarn -Phadoop-2.4 -Dhadoop.version=2.4.0 -DskipTests clean package
