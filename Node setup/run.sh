           
echo "      _____        _____                          ____   	
echo "  ___|\    \   ___|\    \  _____      _____  ____|\   \  
echo " /    /\    \ |    |\    \ \    \    /    / /    /\    \ 
echo "|    |  |    ||    | |    | \    \  /    / |    |  |    |
echo "|    |  |____||    |/____/   \____\/____/  |    |__|    |
echo "|    |   ____ |    |\    \   /    /\    \  |    .--.    |
echo "|    |  |    ||    | |    | /    /  \    \ |    |  |    |
echo "|\ ___\/    /||____| |____|/____/ /\ \____\|____|  |____|
echo "| |   /____/ ||    | |    ||    |/  \|    ||    |  |    |
echo " \|___|    | /|____| |____||____|    |____||____|  |____|
echo "   \( |____|/   \(     )/    \(        )/    \(      )/  
echo "    '   )/       '     '      '        '      '      '   
echo "        '                                                

echo "Telegram : https://t.me/airdropfind"
echo "Twitter  : https://twitter.com/Crk170619"
sleep 5

echo -e "\n==========INSTALLING DEPENDENCIES==========\n"
sleep 2

if [ -s /usr/local/bin/humansd ]; then
    sudo rm -rf /usr/local/bin/humansd
fi

if [ -s humans_latest_linux_amd64.tar.gz ]; then
    rm $HOME/humans_latest_linux_amd64.tar.gz
fi

wget https://github.com/humansdotai/humans/releases/download/latest/humans_latest_linux_amd64.tar.gz
tar -xvf humans_latest_linux_amd64.tar.gz
sudo mv humansd /usr/local/bin/humansd
rm -rf humans_latest_linux_amd64.tar.gz

if [ ! $HUMAN_MONIKER ]; then
    read -p "Enter node name: " HUMAN_MONIKER
    echo 'export HUMAN_MONIKER='\"${HUMAN_MONIKER}\" >> $HOME/.bashrc
    echo 'export HUMAN_CHAIN_ID="testnet-1"' >> $HOME/.bashrc
fi

source $HOME/.bashrc

if [ -d $HOME/.humans ]; then
    rm -rf $HOME/.humans
fi

if [ -s $HOME/persistent_peers.txt ]; then
    rm $HOME/persistent_peers.txt
fi

humansd init $HUMAN_MONIKER --chain-id=$HUMAN_CHAIN_ID --home $HOME/.humans
curl -s https://rpc-testnet.humans.zone/genesis | jq -r .result.genesis > $HOME/.humans/config/genesis.json
SEEDS=""
PEERS="1df6735ac39c8f07ae5db31923a0d38ec6d1372b@45.136.40.6:26656,9726b7ba17ee87006055a9b7a45293bfd7b7f0fc@45.136.40.16:26656,6e84cde074d4af8a9df59d125db3bf8d6722a787@45.136.40.18:26656,eda3e2255f3c88f97673d61d6f37b243de34e9d9@45.136.40.13:26656,4de8c8acccecc8e0bed4a218c2ef235ab68b5cf2@45.136.40.12:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HUMANS_PORT}317\"%;
s%^address = \":8080\"%address = \":${HUMANS_PORT}080\"%;
s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HUMANS_PORT}090\"%; 
s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HUMANS_PORT}091\"%; 
s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${HUMANS_PORT}545\"%; 
s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${HUMANS_PORT}546\"%" $HOME/.humans/config/app.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HUMANS_PORT}658\"%; 
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${HUMANS_PORT}657\"%; 
s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HUMANS_PORT}060\"%;
s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HUMANS_PORT}656\"%;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${HUMANS_PORT}656\"%;
s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HUMANS_PORT}660\"%" $HOME/.humans/config/config.toml

sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.humans/config/app.toml

CONFIG_TOML="$HOME/.humans/config/config.toml"
 sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
 sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML
 
humansd tendermint unsafe-reset-all --home $HOME/.humans --keep-addr-book

sudo tee /etc/systemd/system/humansd.service > /dev/null <<EOF
[Unit]
Description=humans
After=network-online.target

[Service]
User=$USER
ExecStart=$(which humansd) start --home $HOME/.humans
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable humansd
sudo systemctl restart humansd && journalctl -u humansd -f --no-hostname -o cat
