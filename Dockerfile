# 使用Alpine 3.18作为基础镜像
FROM alpine:3.18

# 复制JDK压缩包到镜像中
COPY OpenJDK17U-jre_x64_alpine-linux_hotspot_17.0.9_9.tar.gz /tmp/openjdk.tar.gz

# 设置环境变量
ENV JAVA_HOME=/opt/jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# 更新Alpine的软件源为阿里云
RUN echo "https://mirrors.aliyun.com/alpine/v3.18/main" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v3.18/community" >> /etc/apk/repositories

# 安装必要的软件包，包括时区设置和字体支持
RUN apk add --no-cache fontconfig libretls ttf-dejavu tzdata \
    && rm -rf /var/cache/apk/* \
    && echo "Asia/Shanghai" > /etc/timezone \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 解压JDK并清理无用文件
RUN set -eux; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
        --file /tmp/openjdk.tar.gz \
        --directory "$JAVA_HOME" \
        --strip-components 1 \
        --no-same-owner \
    && rm -f /tmp/openjdk.tar.gz \
    && find "$JAVA_HOME" -name '*.diz' -delete \
    && find "$JAVA_HOME" -name '*.txt' -delete \
    && rm -rf "$JAVA_HOME"/man \
    && rm -rf "$JAVA_HOME"/legal

# 清理缓存和临时文件
RUN rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# 可选：打印Java版本信息
CMD ["sh", "-c", "echo 'Java version:' && java -version && echo 'Current date and time:' && date"]