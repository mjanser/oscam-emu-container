FROM alpine:3.18

RUN apk add --no-cache \
    bash \
    xz \
    alpine-release \
    bash \
    ca-certificates \
    coreutils \
    curl \
    jq \
    netcat-openbsd \
    procps-ng \
    shadow \
    tzdata

RUN groupmod -g 1000 users && \
    useradd -u 1000 -U -d /config -s /bin/false user && \
    usermod -G users user && \
    mkdir -p /etc/oscam

RUN apk add --no-cache --virtual=build-dependencies \
        git \
        curl \
        gcc \
        g++ \
        libusb-dev \
        linux-headers \
        make \
        tar && \
    apk add --no-cache \
        ccid \
        libusb \
        openssl-dev

RUN git clone https://github.com/oscam-emu/oscam-patched.git /tmp/oscam-emu && \
    cd /tmp/oscam-emu && \
    git fetch --tags && \
    git checkout $(git tag -l | tail -1) && \
    ./config.sh \
	--enable all \
	--disable \
        CARDREADER_DB2COM \
        CARDREADER_INTERNAL \
        CARDREADER_STINGER \
        CARDREADER_STAPI \
        CARDREADER_STAPI5 \
        IPV6SUPPORT \
        LCDSUPPORT \
        LEDSUPPORT \
        READ_SDT_CHARSETS && \
    make \
        CONF_DIR=/etc/oscam \
        NO_PLUS_TARGET=1 \
        OSCAM_BIN=/usr/bin/oscam && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

EXPOSE 8888
VOLUME /etc/oscam

USER user
CMD oscam
