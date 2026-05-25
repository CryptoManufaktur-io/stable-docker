FROM ubuntu:26.04

RUN apt-get update && apt-get install -y \
    wget curl jq unzip pv lz4 zstd \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://stable-data-dist.s3.us-east-1.amazonaws.com/mainnet/binary/stabled-latest-linux-amd64-mainnet.tar.gz \
    && tar -xzf stabled-latest-linux-amd64-mainnet.tar.gz \
    && mv stabled /usr/local/bin/stabled \
    && rm stabled-latest-linux-amd64-mainnet.tar.gz

RUN useradd -m stable

COPY init.sh /init.sh
RUN chmod +x /init.sh

USER stable
WORKDIR /home/stable