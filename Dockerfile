FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** install JDK17 ****" && \
  mkdir -p /opt/jdk17 && \
  curl -o \
    /tmp/jdk17.tar.gz -L \
    "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6%2B10/OpenJDK17U-jdk_x64_linux_hotspot_17.0.6_10.tar.gz" && \
  tar xf /tmp/jdk17.tar.gz -C \
    /opt/jdk17 && \
  echo "**** install nodejs ****" && \
  mkdir -p /opt/node && \
  curl -o \
    /tmp/node.tar.gz -L \
    "https://nodejs.org/dist/v18.14.2/node-v18.14.2-linux-x64.tar.gz" && \
  tar xf /tmp/node.tar.gz -C \
    /opt/node && \
  echo "**** install maven ****" && \
  mkdir -p /opt/maven && \
  curl -o \
    /tmp/maven.tar.gz -L \
    "https://dlcdn.apache.org/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz" && \
  tar xf /tmp/maven.tar.gz -C \
    /opt/maven && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

##MANUEL COPY-EXTRACT SETTINGS
#COPY /openjdk-17.0.2_linux-x64_bin.tar.gz /opt/
#COPY /node-v18.14.2-linux-x64.tar.gz /opt/
#COPY /apache-maven-3.8.7-linux-bin.tar.gz /opt/
#RUN \
# echo "**** extract files at /opt ****" && \
# cd /opt && \
# tar -xvf openjdk-17.0.2_linux-x64_bin.tar.gz && \
# tar -xvf node-v18.14.2-linux-x64.tar.gz && \
# tar -xvf apache-maven-3.8.7-linux-bin.tar.gz 
#RUN rm -f /opt/openjdk-17.0.2_linux-x64_bin.tar.gz 
#RUN rm -f /opt/node-v18.14.2-linux-x64.tar.gz 
#RUN rm -f /opt/apache-maven-3.8.7-linux-bin.tar.gz 
#RUN echo 'export JAVA_HOME=/opt/jdk-17.0.2' >> ~/.bashrc
#RUN echo 'export PATH=/opt/maven/apache-maven-3.9.0/bin:/opt/node/node-v18.14.2-linux-x64/bin:/opt/jdk-17.0.2/bin/:$PATH' >> ~/.bashrc



RUN echo 'export JAVA_HOME=/opt/jdk17/jdk-17.0.6+10' >> ~/.bashrc
RUN echo 'export PATH=/opt/maven/apache-maven-3.9.0/bin:/opt/node/node-v18.14.2-linux-x64/bin:/opt/jdk17/jdk-17.0.6+10/bin/:$PATH' >> ~/.bashrc

RUN echo 'alias ls="ls -halp"' >> ~/.bashrc
RUN echo 'alias cls="clear"' >> ~/.bashrc
RUN echo 'alias cd..="cd .."' >> ~/.bashrc
RUN echo 'alias ci="mvn clean compile -DskipTests"' >> ~/.bashrc
RUN echo 'alias q="exit"' >> ~/.bashrc

# Olası SSL hatalarını almamak adına doğrulamayı kapat
RUN git config --global http.sslVerify 'false'
# Github'a pushlayabilmek için gereken kullanıcı bilgileri
RUN git config --global user.name 'Kambaa'
RUN git config --global user.email Kambaa@users.noreply.github.com

# ports and volumes
EXPOSE 8443
