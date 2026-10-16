# Get dasel
FROM ghcr.io/tomwright/dasel:3-alpine AS dasel

FROM ubuntu:26.04

RUN apt-get update && apt-get install -y \
    wget curl jq unzip pv lz4 zstd \
    && rm -rf /var/lib/apt/lists/*

ARG STABLE_VERSION
ARG STABLE_SHA256
RUN test -n "${STABLE_VERSION}" && test -n "${STABLE_SHA256}" \
    && wget -q "https://stable-data-dist.s3.us-east-1.amazonaws.com/mainnet/binary/stabled-${STABLE_VERSION}-linux-amd64-mainnet.tar.gz" \
    && echo "${STABLE_SHA256}  stabled-${STABLE_VERSION}-linux-amd64-mainnet.tar.gz" | sha256sum -c - \
    && tar -xzf "stabled-${STABLE_VERSION}-linux-amd64-mainnet.tar.gz" \
    && mv stabled /usr/local/bin/stabled \
    && rm "stabled-${STABLE_VERSION}-linux-amd64-mainnet.tar.gz"

RUN useradd -m stable

COPY --from=dasel /usr/local/bin/dasel /usr/local/bin/
RUN chmod -R 755 /usr/local/bin/dasel

COPY init.sh /init.sh
RUN chmod +x /init.sh

USER stable
WORKDIR /home/stable
