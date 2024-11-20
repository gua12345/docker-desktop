# 使用 ARM64 的 Debian Slim 基础镜像
FROM debian:bullseye-slim

# 设置环境变量
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

# 配置 Ubuntu 的源并安装必要软件
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
        at-spi2-core \
        build-essential \
        dbus \
        grep \
        iproute2 \
        iputils-ping \
        openbox \
        procps \
        python3-numpy \
        sudo \
        tigervnc-standalone-server \
        fonts-wqy-zenhei \
        xterm \
        wget \
        novnc && \
    echo "abc ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置默认语言
RUN echo "LANG=en_US.UTF-8" > /etc/default/locale && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# 创建并设置默认用户
RUN useradd -m -s /bin/bash abc && \
    mkdir -p /config && \
    chown -R abc:abc /config

# 拷贝必要的配置文件到容器中
COPY /root /
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run

# 暴露端口和挂载点
EXPOSE 5901 6081
VOLUME /config

# 设置默认用户和启动命令
USER abc
CMD ["bash"]
