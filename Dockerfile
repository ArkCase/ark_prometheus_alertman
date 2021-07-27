ARG ARCH="amd64"
ARG OS="linux"
FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest
LABEL maintainer="Armedia, LLC"

ARG ARCH="amd64"
ARG OS="linux"
ARG VER="0.22.2"
ARG PKG="alertmanager"
ARG SRC="${PKG}-${VER}.${OS}-${ARCH}"

RUN curl \
		-L "https://github.com/prometheus/${PKG}/releases/download/v${VER}/${SRC}.tar.gz" \
		-o package.tar.gz && \
	tar -xzvf "package.tar.gz" && \
	mkdir -pv "/etc/alertmanager" && \
	mkdir -p "/alertmanager" && \
	mv -vif "${SRC}/LICENSE"                     "/LICENSE" && \
	mv -vif "${SRC}/NOTICE"                      "/NOTICE" && \
	mv -vif "${SRC}/amtool"                      "/bin/amtool" && \
	mv -vif "${SRC}/alertmanager"                "/bin/alertmanager" && \
	mv -vif "${SRC}/alertmanager.yml"            "/etc/alertmanager/alertmanager.yml" && \
    chown -R nobody:nobody "/etc/alertmanager" "/alertmanager" && \
	rm -rvf "${SRC}" package.tar.gz

USER       nobody
EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]
