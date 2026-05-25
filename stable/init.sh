#!/bin/bash
set -e

MONIKER="${MONIKER:-stable-rpc}"
CHAIN_ID="stable_988-1"
HOME_DIR="/home/stable/.stabled"

if [ -f "$HOME_DIR/config/genesis.json" ]; then
    echo "Already initialized, skipping."
else
    echo "Initializing node..."

    stabled init "$MONIKER" --chain-id "$CHAIN_ID"

    # Genesis
    wget -q https://stable-data-dist.s3.us-east-1.amazonaws.com/mainnet/configuration/genesis.zip
    unzip -q genesis.zip
    cp genesis.json "$HOME_DIR/config/genesis.json"
    rm -f genesis.zip genesis.json
    # Verify: sha256sum $HOME_DIR/config/genesis.json
    # Expected: e1ceda79a3cc48a1028ca8646a2e9e2d156f610637cfb8b428ca8354277921f1

    # Archive node config.toml
    wget -q https://stable-data-dist.s3.us-east-1.amazonaws.com/mainnet/configuration/archive_node_config.zip
    unzip -q archive_node_config.zip
    cp config.toml "$HOME_DIR/config/config.toml"
    sed -i "s/^moniker = \".*\"/moniker = \"$MONIKER\"/" "$HOME_DIR/config/config.toml"
    rm -f archive_node_config.zip config.toml

    echo "Init complete."
fi


stabled start --chain-id stable_988-1
