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

dasel put -v "true" -f /home/stable/.stabled/config/app.toml 'json-rpc.enable'
dasel put -v "0.0.0.0:8545" -f /home/stable/.stabled/config/app.toml 'json-rpc.address'
dasel put -v "0.0.0.0:8546" -f /home/stable/.stabled/config/app.toml 'json-rpc.ws-address'
dasel put -v "true" -f /home/stable/.stabled/config/app.toml 'json-rpc.allow-unprotected-txs'

dasel put -v "50" -f /home/stable/.stabled/config/config.toml 'p2p.max_num_inbound_peers'
dasel put -v "30" -f /home/stable/.stabled/config/config.toml 'p2p.max_num_outbound_peers'

dasel put -v "9aa181b20248e948567cb47a15eae35d58cd549d@seed1.stable.xyz:46656" -f /home/stable/.stabled/config/config.toml 'p2p.seeds'
dasel put -v "b896f6f8ca5a4d1cc40de09407df0c96e76df950@peer1.stable.xyz:26656" -f /home/stable/.stabled/config/config.toml 'p2p.persistent_peers'
dasel put -v "true" -f /home/stable/.stabled/config/config.toml 'p2p.pex'
dasel put -v "tcp://0.0.0.0:26657" -f /home/stable/.stabled/config/config.toml 'rpc.laddr'
dasel put -v "900" -f /home/stable/.stabled/config/config.toml 'rpc.max_open_connections'
dasel put -v "[*]" -f /home/stable/.stabled/config/config.toml 'rpc.cors_allowed_origins'

stabled start --chain-id stable_988-1
