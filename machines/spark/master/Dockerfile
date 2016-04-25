FROM gettyimages/spark

# # [ Spark ]
# # Spark dependencies
#
# ## Java
# RUN apt-get install -yq python-software-properties
# RUN apt-get install -yq default-jdk ant
# # RUN apt-add-repository ppa:webupd8team/java
# # RUN apt-get update -yq
# # RUN apt-get install -yq --no-install-recommends oracle-java7-installer
# #
# # Scala
# RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
# RUN dpkg -i scala-2.11.8.deb
# ## Py4J
# RUN pip install py4j
# WORKDIR /usr/local
# # ## Spark
# RUN curl -sL -o "/usr/local/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"
#
# RUN tar xvf "spark-$SPARK_VERSION.tgz" && \
#     mv "/usr/local/spark-$SPARK_VERSION" "$SPARK_HOME"
#
# RUN cd "$SPARK_HOME" && build/sbt assembly
