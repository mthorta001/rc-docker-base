FROM ubuntu:20.04

LABEL maintainer="Swain Zheng"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

#==================
# General Packages
#------------------
# openjdk-8-jdk
#   Java
# ca-certificates
#   SSL client
# tzdata
#   Timezone
# zip
#   Make a zip file
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# wget
#   Network downloader
# libqt5webkit5
#   Web content engine (Fix issue in Android)
# libgconf-2-4
#   Required package for chrome and chromedriver to run on Linux
# xvfb
#   X virtual framebuffer
# gnupg
#   Encryption software. It is needed for nodejs
#==================
RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    openjdk-8-jdk \
    ca-certificates \
    tzdata \
    zip \
    unzip \
    curl \
    wget \
    libqt5webkit5 \
    libgconf-2-4 \
    build-essential \
    libssl-dev \
    git \
    xvfb \
    gnupg \
  && rm -rf /var/lib/apt/lists/*

ENV ANDROID_COMMAND_LINE_TOOLS_HOME=/root/cmdline-tools

#===============
# Set JAVA_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    PATH=$PATH:$JAVA_HOME/bin

# install android command line tools
RUN wget -O tools.zip https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip && \
    unzip tools.zip && rm tools.zip && \
    chmod a+x -R $ANDROID_COMMAND_LINE_TOOLS_HOME && \
    chown -R root:root $ANDROID_COMMAND_LINE_TOOLS_HOME

ENV PATH=$PATH:$ANDROID_COMMAND_LINE_TOOLS_HOME/bin \
    ANDROID_HOME = /root

# install platform-tools
RUN echo y | sdkmanager "platform-tools" --sdk_root=$ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/platform-tools

# install cmake
RUN mkdir ~/tmp && \
    cd ~/tmp && \
    wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0.tar.gz && \
    tar -zxvf cmake-3.20.0.tar.gz && \
    cd cmake-3.20.0 && \
    ./bootstrap && \
    make && \
    make install && \
    rm -rf ~/tmp

# install latest nodejs and opencv4nodejs
# install nodejs via ppa
# in this case, npm already installed
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash && \
    apt-get -qqy install nodejs && \
    npm install -g opencv4nodejs --unsafe-perm=true --allow-root && \
    exit 0 && \
    npm cache clean && \
    apt-get remove --purge -y npm && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean

# set time zone
ENV TZ="Asia/Shanghai"
RUN echo "${TZ}" > /etc/timezone





