FROM ghcr.io/linuxserver/baseimage-arch:latest

ENV DEBIAN_FRONTEND=noninteractive \
    WINDOWMANAGER=openbox \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    DISPLAY=:0 \
    VNC_TITLE=TigerVNC \
    VNC_HOST=127.0.0.1 \
    VNC_PORT=5901 \
    VNC_GEOMETRY=1280x800 \
    NOVNC_HOST=0.0.0.0 \
    NOVNC_PORT=6081 \
    HOME=/config

RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    mkdir -p /usr/share/man/man1 && \
    chsh -s /bin/bash abc

# 修改为 Arch Linux ARM 官方源
RUN echo 'Server = http://mirror.archlinuxarm.org/$arch/$repo' > /etc/pacman.d/mirrorlist && \
    pacman-key --init && pacman-key --populate archlinuxarm && \
    pacman -Sy --noconfirm --needed \
        at-spi2-core \
        base-devel \
        dbus \
        grep \
        iproute2 \
        iputils \
        openbox \
        procps-ng \
        python-numpy \
        sudo \
        tigervnc \
        wqy-zenhei \
        xterm && \
    echo '[archlinuxcn]' >> /etc/pacman.conf && \
    echo 'Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf && \
    pacman -Sy --noconfirm --needed archlinuxcn-keyring && \
    pacman -Sy --noconfirm --needed yay && \
    exec s6-setuidgid abc \
        yay -Sy --noconfirm --needed \
            novnc && \
    pacman -Rs base-devel && \
    pacman -Rs $(pacman -Qdtq) && \
    yay -Scc --noconfirm && \
    pacman -Scc --noconfirm && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/* \
        /var/lib/pacman/sync/* \
        /config/.cache/yay/*

COPY /root /
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run

EXPOSE 5901 6081
VOLUME /config
