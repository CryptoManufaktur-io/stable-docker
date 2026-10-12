# Get dasel
FROM ghcr.io/tomwright/dasel:2-alpine AS dasel

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    wget curl jq unzip pv lz4 zstd \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://stable-data-dist.s3.us-east-1.amazonaws.com/mainnet/binary/stabled-1.8.0-linux-amd64-mainnet.tar.gz \
    && echo "39ae0bf81e3932141a9275eb72e52adad0a906ac5e73429bf09fb5cba4dab343  stabled-1.8.0-linux-amd64-mainnet.tar.gz" | sha256sum -c - \
    && tar -xzf stabled-1.8.0-linux-amd64-mainnet.tar.gz \
    && mv stabled /usr/local/bin/stabled \
    && rm stabled-1.8.0-linux-amd64-mainnet.tar.gz

RUN useradd -m stable

COPY --from=dasel /usr/local/bin/dasel /usr/local/bin/
RUN chmod -R 755 /usr/local/bin/dasel

COPY init.sh /init.sh
RUN chmod +x /init.sh

USER stable
WORKDIR /home/stable
