FROM java:8

LABEL maintainer="Facundo Rodriguez <facundo@metacell.us>"

ENV HOME=/home/developer \
  VIRGO_RELEASE=3.7.2 \
  MAVEN_VERSION=3.5.2 \
  MAVEN_HOME=/opt/maven \
  SERVER_HOME=/home/developer/virgo

ENV PATH=$PATH:$MAVEN_HOME/bin \
  GITLFS_HTTP=https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh \
  MAVEN_HTTP=http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  VIRGO_HTTP=http://www.eclipse.org/downloads/download.php?file=/virgo/release/VP/$VIRGO_RELEASE.RELEASE/virgo-tomcat-server-$VIRGO_RELEASE.RELEASE.zip&r=1
  
RUN useradd -ms /bin/bash developer

COPY sources.list /etc/apt/sources.list
RUN rm /etc/apt/sources.list.d/jessie-backports.list

# install required packages
RUN apt-get -o Acquire::Check-Valid-Until=false -qq update &&\
  apt-get -yq install --no-install-recommends \
    sudo \
    xvfb \
    curl \
    bsdtar \
    net-tools \
    locate &&\
  curl -sL ${GITLFS_HTTP} | sed -E "s/apt-get update/apt-get -o Acquire::Check-Valid-Until=false update/g" | sudo -E bash - &&\
  apt-get -o Acquire::Check-Valid-Until=false -yq install --no-install-recommends git-lfs &&\
  git lfs install &&\
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/sudoers.d $MAVEN_HOME $SERVER_HOME $HOME/geppetto &&\
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer && \
    chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

# install maven
RUN wget -qO- $MAVEN_HTTP | tar xzf - -C $MAVEN_HOME --strip-components 1 && mvn --version

USER developer
WORKDIR $HOME

# install virgo
RUN curl -L $VIRGO_HTTP | bsdtar -xzf - -C $SERVER_HOME --strip-components 1
COPY --chown=1000:1000 dmk.sh $SERVER_HOME/bin/
COPY --chown=1000:1000 java-server.profile $SERVER_HOME/configuration/
COPY --chown=1000:1000 tomcat-server.xml $SERVER_HOME/configuration/
COPY --chown=1000:1000 copy.sh $HOME
COPY --chown=1000:1000 rename.sh $HOME
RUN chmod u+x $SERVER_HOME/bin/*.sh

CMD [ "/bin/bash" ]