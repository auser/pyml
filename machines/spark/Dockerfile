# FROM gettyimages/spark
# FROM wielandbrendel/ldap-xserver:cuda7.0-cudnn3
# FROM bethgelab/jupyter-deeplearning:cuda7.5-cudnn4
FROM auser/python23

USER root

ENV SPARK_VERSION "1.6.1"
ENV SPARK_HOME "/usr/local/spark"
ENV SPARK_INSTALL_DIR "/usr/local/src"

ENV SCALA_VERSION 2.11.7
ENV SBT_VERSION 0.13.11

ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# [ Spark ]
# Spark dependencies

## Java
RUN apt-get update -yq
RUN apt-get install -yq curl python-software-properties software-properties-common
# RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Scala
# RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
# RUN dpkg -i scala-2.11.8.deb

RUN chown compute $SPARK_INSTALL_DIR
RUN chown compute $(dirname $SPARK_HOME)
USER compute
WORKDIR $SPARK_INSTALL_DIR
# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C $SPARK_INSTALL_DIR/ && \
  echo >> $HOME/.bashrc && \
  echo 'export PATH=$SPARK_INSTALL_DIR/scala-$SCALA_VERSION/bin:$PATH' >> $HOME/.bashrc

# Install sbt
RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C $SPARK_INSTALL_DIR && \
    echo -ne "- with sbt $SBT_VERSION\n" >> $SPARK_INSTALL_DIR/.built

# Install Python 3 packages
RUN source activate py3 && \
    conda install --quiet --yes \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

RUN source activate py2 && \
    conda install --quiet --yes \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

# ## Spark
RUN curl -sL -o "$SPARK_INSTALL_DIR/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"

RUN echo "yay: $SPARK_INSTALL_DIR" && pwd
RUN cd $SPARK_INSTALL_DIR && \
    pwd && \
    tar xf "spark-$SPARK_VERSION.tgz" && \
    mv "$SPARK_INSTALL_DIR//spark-$SPARK_VERSION" "$SPARK_HOME"

ENV MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

RUN cd "$SPARK_HOME" && \
    build/mvn -Pyarn -Phadoop-2.4 -Dhadoop.version=2.4.0 -DskipTests clean package

## CLEAN UP
USER root
RUN apt-get clean autoclean -yq && \
    apt-get autoremove -yq

# RUN rm -rf /tmp/* /var/tmp/*
#
# RUN rm -rf /var/lib/apt/lists/*
# ## CLEAN UP


USER compute
