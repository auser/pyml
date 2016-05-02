# FROM gettyimages/spark
# FROM wielandbrendel/ldap-xserver:cuda7.0-cudnn3
FROM auser/python23

USER root

ENV SPARK_VERSION "1.6.1"
ENV SPARK_HOME "/usr/local/spark"

ENV SCALA_VERSION 2.11.7
ENV SBT_VERSION 0.13.11

ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# [ Spark ]
# Spark dependencies

## Java
RUN apt-get update -yq
RUN apt-get install -yq python-software-properties software-properties-common python3-software-properties curl
RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
RUN apt-get update -yq
RUN apt-get install -yq openjdk-8-jdk ant

# Scala
# RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
# RUN dpkg -i scala-2.11.8.deb

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

# Install Python 3 packages
RUN conda install --quiet --yes \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

RUN conda install --quiet --yes \
    -p $CONDA_DIR/envs/python2 \
    -c anaconda-cluster \
    py4j && \
    conda clean -tipsy

## Py4J
WORKDIR /usr/local
# ## Spark
RUN curl -sL -o "/usr/local/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"

RUN tar xvf "spark-$SPARK_VERSION.tgz" && \
    mv "/usr/local/spark-$SPARK_VERSION" "$SPARK_HOME"

ENV MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

RUN cd "$SPARK_HOME" && \
    build/mvn -Pyarn -Phadoop-2.4 -Dhadoop.version=2.4.0 -DskipTests clean package
    # build/sbt -Pyarn -Phadoop-2.3 assembly
    # ${SBT_HOME}/bin/sbt assembly

USER jovyan
