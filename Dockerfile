ARG ARCH="amd64"
ARG OS="linux"
#FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest
FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest
LABEL maintainer="Armedia, LLC"

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="0.22.2"
ARG PKG="alertmanager"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"

RUN curl -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" -o package.tar.gz
RUN tar -xzvf "package.tar.gz"
RUN mv -vif "${SRC}/LICENSE"                     "/LICENSE"
RUN mv -vif "${SRC}/NOTICE"                      "/NOTICE"

RUN mv -vif "${SRC}/amtool"                      "/bin/amtool"
RUN mv -vif "${SRC}/alertmanager"                "/bin/alertmanager"

RUN mkdir -pv "/etc/alertmanager"
RUN mv -vif "${SRC}/alertmanager.yml"            "/etc/alertmanager/alertmanager.yml"

RUN mkdir -p /alertmanager && \
    chown -R nobody:nobody etc/alertmanager /alertmanager

# Cleanup
RUN rm -rvf "${SRC}" package.tar.gz

USER       nobody
EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]
