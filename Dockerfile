ARG LANGS=
FROM node:8.14.0-alpine
ARG LANGS
RUN mkdir -p out
ADD gen gen
RUN cd gen && npm install
ADD languages languages
ADD packages.txt packages.txt
RUN node gen/index.js

FROM ubuntu:18.04

COPY --from=0 /out/phase0.sh /phase0.sh
RUN /bin/bash phase0.sh

ENV XDG_CONFIG_HOME=/config

COPY --from=0 /out/phase1.sh /phase1.sh
RUN /bin/bash phase1.sh

COPY --from=0 /out/phase2.sh /phase2.sh
RUN /bin/bash phase2.sh

RUN echo '[core]\n    excludesFile = /etc/.gitignore' > /etc/gitconfig
ADD polygott-gitignore /etc/.gitignore

COPY --from=0 /out/run-project /usr/bin/run-project
COPY --from=0 /out/run-language-server /usr/bin/run-language-server
COPY --from=0 /out/detect-language /usr/bin/detect-language
COPY --from=0 /out/self-test /usr/bin/polygott-self-test
COPY --from=0 /out/polygott-survey /usr/bin/polygott-survey
COPY --from=0 /out/polygott-lang-setup /usr/bin/polygott-lang-setup
COPY --from=0 /out/polygott-x11-vnc /usr/bin/polygott-x11-vnc

ENV JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64

RUN curl -O https://www-us.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz && \
tar xvf spark-2.4.4-bin-hadoop2.7.tgz && \
mv spark-2.4.4-bin-hadoop2.7/ /opt/spark &&\
curl -O https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz && \
tar -xzvf hadoop-2.7.7.tar.gz && \
mv hadoop-2.7.7 /usr/local/hadoop



ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME HADOOP_MAPRED_HOME=$HADOOP_HOME HADOOP_COMMON_HOME=$HADOOP_HOME HADOOP_HDFS_HOME=$HADOOP_HOME YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

WORKDIR /home/runner

