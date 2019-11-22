FROM unionpos/ubuntu:16.04

ENV VERSION 0.18.0
ENV DOWNLOAD_FILE "alertmanager-${VERSION}.linux-amd64.tar.gz"
ENV DOWNLOAD_URL "https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/${DOWNLOAD_FILE}"
ENV DOWNLOAD_SHA 5f17155d669a8d2243b0d179fa46e609e0566876afd0afb09311a8bc7987ab15

RUN set -ex \
    && buildDeps=' \
    ca-certificates \
    wget \
    ' \
    && apt-get update -qq \
    && apt-get install -qq -y $buildDeps \
    && wget -O "$DOWNLOAD_FILE" "$DOWNLOAD_URL" \
    && apt-get autoremove -qq -y $buildDeps && rm -rf /var/lib/apt/lists/* \
    && echo "${DOWNLOAD_SHA} *${DOWNLOAD_FILE}" | sha256sum -c - \
    && tar xfvz "$DOWNLOAD_FILE" --strip-components=1 -C "/tmp" \
    && mv "/tmp/alertmanager" /bin/alertmanager \
    && mv "/tmp/amtool" /bin/amtool \
    && mkdir /etc/alertmanager \
    && mv "/tmp/alertmanager.yml" /etc/alertmanager/alertmanager.yml \
    && rm /tmp/LICENSE \
    && rm /tmp/NOTICE \
    && rm "$DOWNLOAD_FILE"


RUN mkdir -p /alertmanager \
    && chown -R nobody:nogroup etc/alertmanager /alertmanager

USER       nobody
# EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", "--storage.path=/alertmanager" ]
