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

# Upgrade Archlinux and install devel packages
RUN apt-get update \
    && apt-get remove -y \
        openjdk-* \
        icedtea-* \
    && apt-get install -y sudo zsh \
        git bc rsync imagemagick ccache lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib python-networkx libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip python-pip python-dev libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev openjdk-8-jdk

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
