# todo : https://android.googlesource.com/platform/build/+/master/tools/docker/Dockerfile

# android-build-image with Ubuntu
# - https://nathanpfry.com/how-to-setup-ubuntu-18-04-lts-bionic-beaver-to-compile-android-roms/

FROM ubuntu:14.04

MAINTAINER Julien Milletre Akipe <code.julien@milletre.fr>


ENV \
    # user
    UID=1000 \
    GID=1000 \
    # ccache specifics
    CCACHE_SIZE=50G \
    CCACHE_DIR=/android/ccache \
    USE_CCACHE=1 \
    CCACHE_COMPRESS=1 \
    # java
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk \
    ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G" \
    # other
    LC_ALL=C


######
### Init Archlinux
######

# Upgrade Archlinux and install devel packages
RUN apt-get update \
    && apt-get dist-upgrade --yes \
    && apt-get remove --yes \
        openjdk-* \
        icedtea-* \
    && apt-get install --yes \
        bc \
        bison \
        build-essential \
        ccache \
        curl \
        flex \
        g++-multilib \
        gcc-multilib \
        git \
        gnupg \
        gperf \
        imagemagick \
        lib32ncurses5-dev \
        lib32readline-dev \
        lib32z-dev \
        lib32z1-dev \
        liblz4-tool \
        libc6-dev-i386 \
        libgl1-mesa-dev \
        libncurses5 \
        libncurses5-dev \
        libsdl1.2-dev \
        libssl-dev \
        libwxgtk2.8-dev \
        libx11-dev \
        libxml2 \
        libxml2-utils \
        pngcrush \
        python-pip \
        python-virtualenv \
        python3-dev \
        python3-pip \
        lzop \
        rsync \
        schedtool \
        software-properties-common \
        squashfs-tools \
        sudo \
        unzip \
        x11proto-core-dev \
        xsltproc \
        zip \
        zlib1g-dev \
    && add-apt-repository ppa:openjdk-r/ppa --yes \
    && apt-get update \
    && apt-get install openjdk-8-jdk --yes
        
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
    && chmod a+x /usr/bin/repo

# RUN pip install virtualenv

######
### Create user
######

RUN groupadd --gid $GID --force builder \
    && useradd --gid $GID --uid $UID --non-unique builder \
    && mkdir /home/builder \
    && chown -R builder:builder /home/builder \
    && echo "builder ALL=NOPASSWD: ALL" > /etc/sudoers.d/builder


USER builder


######
### Android build tools
######

# Create working directory
RUN sudo mkdir /android \
    && sudo chown -R builder:builder /android

WORKDIR /android

# Configure Python version
RUN virtualenv --system-site-packages venv
#    && ln -s /usr/lib/python2.7/* /android/venv/lib/python2.7/ \
#    && source venv/bin/activate


COPY ./docker/ubuntu/entrypoint.sh /

RUN sudo chmod +x /entrypoint.sh \
    && sudo chown -R builder:builder /entrypoint.sh

CMD /entrypoint.sh
