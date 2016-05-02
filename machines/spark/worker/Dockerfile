# FROM gettyimages/spark
FROM ubuntu:14.04

ENV SPARK_VERSION "1.6.1"
ENV SPARK_HOME "/usr/local/spark"

# [ Spark ]
# Spark dependencies

## Java
RUN apt-get install -yq python-software-properties
RUN apt-get install -yq default-jdk ant
# RUN apt-add-repository ppa:webupd8team/java
# RUN apt-get update -yq
# RUN apt-get install -yq --no-install-recommends oracle-java7-installer
#
# Scala
RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
RUN dpkg -i scala-2.11.8.deb
## Py4J
RUN pip install py4j
WORKDIR /usr/local
# ## Spark
RUN curl -sL -o "/usr/local/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"

RUN tar xvf "spark-$SPARK_VERSION.tgz" && \
    mv "/usr/local/spark-$SPARK_VERSION" "$SPARK_HOME"

RUN cd "$SPARK_HOME" && build/sbt assembly

# Remove preinstalled copy of python that blocks our ability to install development python.
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get remove -yq \
        python3-minimal \
        python3.4 \
        python3.4-minimal \
        libpython3-stdlib \
        libpython3.4-minimal \
        libpython3.4-stdlib \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Python binary and source dependencies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libcurl4-openssl-dev \
        libffi-dev \
        libsqlite3-dev \
        libzmq3-dev \
        pandoc \
        python \
        python3 \
        python-dev \
        python3-dev \
        sqlite3 \
        texlive-fonts-recommended \
        texlive-latex-base \
        texlive-latex-extra \
        vim \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
