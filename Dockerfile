FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="0.23.0"
ARG PKG="alertmanager"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"
ARG UID="471"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia Devops Team <devops@armedia.com>"
LABEL APP="Prometheus Alert Manager"
LABEL VERSION="${VER}"
LABEL IMAGE_SOURCE="https://github.com/ArkCase/ark_prometheus_alertman"

#
# Create the required user
#
RUN useradd --system --uid ${UID} --user-group prometheus

#
# Download the primary artifact
#
RUN curl \
        -L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
        -o - | tar -xzvf -

#
# Create the necessary directories
#
RUN mkdir -pv "/app/data" "/app/conf"

#
# Deploy the extracted files
#
RUN mv -vif "${SRC}/LICENSE"          "/LICENSE"
RUN mv -vif "${SRC}/NOTICE"           "/NOTICE"
RUN mv -vif "${SRC}/amtool"           "/usr/bin/amtool"
RUN mv -vif "${SRC}/alertmanager"     "/usr/bin/alertmanager"
RUN mv -vif "${SRC}/alertmanager.yml" "/app/conf/alertmanager.yml"

#
# Create any missing links
#
RUN ln -sv "/app/conf" "/etc/alertmanager"
RUN ln -sv "/app/conf" "/etc/amtool"

#
# Set ownership + permissions
#
RUN chown -R prometheus:    "/app/data" "/app/conf"
RUN chmod -R ug+rwX,o-rwx "/app/data" "/app/conf"

#
# Cleanup
#
RUN rm -rvf "${SRC}"

#
# Final parameters
#
USER        prometheus
EXPOSE      9093
VOLUME      [ "/app/data", "/app/conf" ]
WORKDIR     /app/data
ENTRYPOINT  [ "/usr/bin/alertmanager" ]
CMD         [ "--config.file=/app/conf/alertmanager.yml", \
              "--storage.path=/app/data" ]
