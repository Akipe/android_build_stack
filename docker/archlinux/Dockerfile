# android-build-image with Archlinux
# - https://github.com/greyltc/docker-archlinux-aur/blob/master/add-aur.sh
# - https://android.googlesource.com/platform/build/+/master/tools/docker

FROM archlinux/base

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

# Enable Multilib repository
RUN sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Upgrade Archlinux and install devel packages
RUN pacman -Syyu --noprogressbar --noconfirm --needed \
        base-devel \
        multilib-devel \
        git \
        sudo \
        pacman \
        go \
        vim \
        nano \
        vi


######
### Create user
######

RUN groupadd --gid $GID --force build \
    && useradd --gid $GID --uid $UID --non-unique build \
    && mkdir /home/build \
    && chown -R build:build /home/build \
    && echo "build ALL=NOPASSWD: ALL" > /etc/sudoers.d/build


######
### AUR
######

# Use all possible cores for subsequent package builds &&
#   don't compress the packages built here
RUN sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf \
    && sed -i "s,PKGEXT='.pkg.tar.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

USER build

# Install yay
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay \
    && cd /tmp/yay \
    && makepkg \
    && sudo pacman -U *.pkg.tar --noprogressbar --noconfirm \
    && rm -rf /tmp/yay


######
### Android build tools
######

# Install dependecies for building Android
RUN yay -S --noprogressbar --needed --noconfirm \
        aosp-devel \
        lineageos-devel \
        jdk7-openjdk \
        jdk8-openjdk \
        repo \
        maven \
        gradle

# Create working directory
RUN sudo mkdir /android \
    && sudo chown -R build:build /android

WORKDIR /android

# Configure Python version
RUN sudo ln -s /usr/bin/python2 /usr/bin/python \
    && virtualenv2 --system-site-packages venv \
#    && ln -s /usr/lib/python2.7/* /android/venv/lib/python2.7/ \
    && source venv/bin/activate

RUN sudo archlinux-java set java-8-openjdk

COPY ./archlinux/entrypoint.sh /

RUN sudo chmod +x /entrypoint.sh \
    && sudo chown -R build:build /entrypoint.sh

CMD /entrypoint.sh