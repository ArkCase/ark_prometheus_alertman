FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="0.22.2"
ARG PKG="alertmanager"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"
ARG UID="nobody"
ARG GID="nobody"

LABEL   ORG="Armedia LLC" \
        APP="Prometheus Alert Manager" \
        VERSION="${VER}" \
        IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus_alertman" \
        MAINTAINER="Armedia LLC"

# Modify to fetch from S3 ...
RUN curl \
        -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
        -o "package.tar.gz" && \
    tar -xzvf "package.tar.gz" && \
    mkdir -pv \
        "/app/data" \
        "/app/conf" && \
    ln -sv \
        "/app/conf" \
        "/etc/alertmanager" && \
    ln -sv \
        "/app/conf" \
        "/etc/amtool" && \
    mv -vif \
        "${SRC}/LICENSE" \
        "/LICENSE" && \
    mv -vif \
        "${SRC}/NOTICE" \
        "/NOTICE" && \
    mv -vif \
        "${SRC}/amtool" \
        "/bin/amtool" && \
    mv -vif \
        "${SRC}/alertmanager" \
        "/bin/alertmanager" && \
    mv -vif \
        "${SRC}/alertmanager.yml" \
        "/app/conf/alertmanager.yml" && \
    chown -R "${UID}:${GID}" \
        "/app/data" \
        "/app/conf" && \
    chmod -R ug+rwX,o-rwx \
        "/app/data" \
        "/app/conf" && \
    rm -rvf \
        "${SRC}" \
        "package.tar.gz"

USER        ${UID}
EXPOSE      9093
VOLUME      [ "/app/data", "/app/conf" ]
WORKDIR     /app/data
ENTRYPOINT  [ "/bin/alertmanager" ]
CMD         [ "--config.file=/app/conf/alertmanager.yml", \
              "--storage.path=/app/data" ]
