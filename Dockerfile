FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="0.22.2"
ARG PKG="alertmanager"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"
ARG UID="nobody"
ARG GID="nobody"

LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia LLC"
LABEL APP="Prometheus Alert Manager"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus_alertman"

# Modify to fetch from S3 ...
RUN curl \
        -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
        -o - | tar -xzvf -
RUN mkdir -pv \
        "/app/data" \
        "/app/conf"
RUN ln -sv \
        "/app/conf" \
        "/etc/alertmanager"
RUN ln -sv \
        "/app/conf" \
        "/etc/amtool"
RUN mv -vif \
        "${SRC}/LICENSE" \
        "/LICENSE"
RUN mv -vif \
        "${SRC}/NOTICE" \
        "/NOTICE"
RUN mv -vif \
        "${SRC}/amtool" \
        "/bin/amtool"
RUN mv -vif \
        "${SRC}/alertmanager" \
        "/bin/alertmanager"
RUN mv -vif \
        "${SRC}/alertmanager.yml" \
        "/app/conf/alertmanager.yml"
RUN chown -R "${UID}:${GID}" \
        "/app/data" \
        "/app/conf"
RUN chmod -R ug+rwX,o-rwx \
        "/app/data" \
        "/app/conf"
RUN rm -rvf \
        "${SRC}"

USER        ${UID}
EXPOSE      9093
VOLUME      [ "/app/data", "/app/conf" ]
WORKDIR     /app/data
ENTRYPOINT  [ "/bin/alertmanager" ]
CMD         [ "--config.file=/app/conf/alertmanager.yml", \
              "--storage.path=/app/data" ]
