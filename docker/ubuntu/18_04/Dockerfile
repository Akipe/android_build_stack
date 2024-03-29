# todo : https://android.googlesource.com/platform/build/+/master/tools/docker/Dockerfile

# android-build-image with Ubuntu
# - https://nathanpfry.com/how-to-setup-ubuntu-18-04-lts-bionic-beaver-to-compile-android-roms/

FROM ubuntu:18.04

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

# Install the build packages
RUN apt-get update \
    && apt-get full-upgrade --yes \
    && apt-get remove --yes \
        openjdk-* \
        icedtea-* \
    && apt-get install --yes \
        bc \
        bison \
        build-essential \
        bzip2 \
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
        lib32z1-dev \
        libbz2-dev \
        libc6-dev-i386 \
        libffi-dev \
        libghc-bzlib-dev \
        libgl1-mesa-dev \
        libjpeg8-dev \
        liblz4-tool \
        libncurses5 \
        libncurses5-dev \
        libsdl1.2-dev \
        libssl-dev \
        libwxgtk3.0-dev \
        libx11-dev \
        libxml2 \
        libxml2-dev \
        libxml2-utils \
        libxslt1-dev \
        lzop \
        openjdk-8-jdk \
        optipng \
        pngcrush \
        python-dev \
        python-networkx \
        python-pip \
        rsync \
        schedtool \
        squashfs-tools \
        sudo \
        unzip \
        x11proto-core-dev \
        xsltproc \
        zip \
        zlib1g-dev

RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
    && chmod a+x /usr/bin/repo

RUN pip install virtualenv

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
