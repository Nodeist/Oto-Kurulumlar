#!/bin/bash
echo -e "\033[0;35m"
echo "  _   _  ____  _____  ______  _______          _______ ______         _____  _____    ";
echo " | \ | |/ __ \|  __ \|  ____|/ ____\ \        / /_   _|___  /   /\   |  __ \|  __ \   ";
echo " |  \| | |  | | |  | | |__  | (___  \ \  /\  / /  | |    / /   /  \  | |__) | |  | |  ";
echo " | |\  | |__| | |__| | |____ ____) |  \  /\  /   _| |_ / /__ / ____ \| | \ \| |__| |  ";
echo " |_| \_|\____/|_____/|______|_____/    \/  \/   |_____/_____/_/    \_\_|  \_\_____/   ";
echo -e "\e[0m"                                 


sleep 2

# DEGISKENLER  
HAQQ_WALLET=wallet
HAQQ=haqqd
HAQQ_ID=haqq_53211-1
HAQQ_PORT=29
HAQQ_FOLDER=.haqqd
HAQQ_FOLDER2=haqq
HAQQ_VER=v1.0.3
HAQQ_REPO=https://github.com/haqq-network/haqq
HAQQ_GENESIS=https://storage.googleapis.com/haqq-testedge-snapshots/genesis.json
HAQQ_ADDRBOOK=
HAQQ_MIN_GAS=0
HAQQ_DENOM=aISLM
HAQQ_SEEDS=8f7b0add0523ec3648cb48bc12ac35357b1a73ae@195.201.123.87:26656,899eb370da6930cf0bfe01478c82548bb7c71460@34.90.233.163:26656,f2a78c20d5bb567dd05d525b76324a45b5b7aa28@34.90.227.10:26656,4705cf12fb56d7f9eb7144937c9f1b1d8c7b6a4a@34.91.195.139:26656
HAQQ_PEERS=

sleep 1

echo "export HAQQ_WALLET=${HAQQ_WALLET}" >> $HOME/.bash_profile
echo "export HAQQ=${HAQQ}" >> $HOME/.bash_profile
echo "export HAQQ_ID=${HAQQ_ID}" >> $HOME/.bash_profile
echo "export HAQQ_PORT=${HAQQ_PORT}" >> $HOME/.bash_profile
echo "export HAQQ_FOLDER=${HAQQ_FOLDER}" >> $HOME/.bash_profile
echo "export HAQQ_FOLDER2=${HAQQ_FOLDER2}" >> $HOME/.bash_profile
echo "export HAQQ_VER=${HAQQ_VER}" >> $HOME/.bash_profile
echo "export HAQQ_REPO=${HAQQ_REPO}" >> $HOME/.bash_profile
echo "export HAQQ_GENESIS=${HAQQ_GENESIS}" >> $HOME/.bash_profile
echo "export HAQQ_PEERS=${HAQQ_PEERS}" >> $HOME/.bash_profile
echo "export HAQQ_SEED=${HAQQ_SEED}" >> $HOME/.bash_profile
echo "export HAQQ_MIN_GAS=${HAQQ_MIN_GAS}" >> $HOME/.bash_profile
echo "export HAQQ_DENOM=${HAQQ_DENOM}" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 1

if [ ! $HAQQ_NODENAME ]; then
	read -p "NODE ISMI YAZINIZ: " HAQQ_NODENAME
	echo 'export HAQQ_NODENAME='$HAQQ_NODENAME >> $HOME/.bash_profile
fi

echo -e "NODE ISMINIZ: \e[1m\e[32m$HAQQ_NODENAME\e[0m"
echo -e "CUZDAN ISMINIZ: \e[1m\e[32m$HAQQ_WALLET\e[0m"
echo -e "CHAIN ISMI: \e[1m\e[32m$HAQQ_ID\e[0m"
echo -e "PORT NUMARANIZ: \e[1m\e[32m$HAQQ_PORT\e[0m"
echo '================================================='

sleep 2


# GUNCELLEMELER  
echo -e "\e[1m\e[32m1. GUNCELLEMELER YUKLENIYOR... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y


# GEREKLI PAKETLER  
echo -e "\e[1m\e[32m2. GEREKLILIKLER YUKLENIYOR... \e[0m" && sleep 1
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y < "/dev/null"

# GO KURULUMU  
cd $HOME
wget -O go1.18.2.linux-amd64.tar.gz https://go.dev/dl/go1.18.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz && rm go1.18.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bashrc
echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
echo 'export GO111MODULE=on' >> $HOME/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc && . $HOME/.bashrc
go version

sleep 1

# KUTUPHANE KURULUMU  
echo -e "\e[1m\e[32m1. REPO YUKLENIYOR... \e[0m" && sleep 1
cd $HOME
git clone -b $HAQQ_VER $HAQQ_REPO
cd $HAQQ_FOLDER2
make install

sleep 1

# KONFIGURASYON  
echo -e "\e[1m\e[32m1. KONFIGURASYONLAR AYARLANIYOR... \e[0m" && sleep 1
$HAQQ config chain-id $HAQQ_ID
$HAQQ config keyring-backend file
$HAQQ init $HAQQ_NODENAME --chain-id $HAQQ_ID

# ADDRBOOK ve GENESIS  
wget $HAQQ_GENESIS -O $HOME/$HAQQ_FOLDER/config/genesis.json
wget $HAQQ_ADDRBOOK -O $HOME/$HAQQ_FOLDER/config/addrbook.json

# EŞLER VE TOHUMLAR  
SEEDS="$HAQQ_SEEDS"
PEERS="$HAQQ_PEERS"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$HAQQ_FOLDER/config/config.toml

sleep 1


# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$HAQQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$HAQQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$HAQQ_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$HAQQ_FOLDER/config/app.toml


# ÖZELLEŞTİRİLMİŞ PORTLAR  
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HAQQ_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${HAQQ_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HAQQ_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HAQQ_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HAQQ_PORT}660\"%" $HOME/$HAQQ_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HAQQ_PORT}317\"%; s%^address = \":8080\"%address = \":${HAQQ_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HAQQ_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HAQQ_PORT}091\"%" $HOME/$HAQQ_FOLDER/config/app.toml
sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:${HAQQ_PORT}657\"%" $HOME/$HAQQ_FOLDER/config/client.toml

# PROMETHEUS AKTIVASYON  
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/$HAQQ_FOLDER/config/config.toml

# MINIMUM GAS AYARI  
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00125$HAQQ_DENOM\"/" $HOME/$HAQQ_FOLDER/config/app.toml

# INDEXER AYARI  
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/$HAQQ_FOLDER/config/config.toml

# RESET  
$HAQQ tendermint unsafe-reset-all --home $HOME/$HAQQ_FOLDER

echo -e "\e[1m\e[32m4. SERVIS BASLATILIYOR... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/$HAQQ.service > /dev/null <<EOF
[Unit]
Description=$HAQQ
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $HAQQ) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# SERVISLERI BASLAT  
sudo systemctl daemon-reload
sudo systemctl enable $HAQQ
sudo systemctl restart $HAQQ

source $HOME/.bash_profile
sleep 2
systemctl stop haqqd
sleep 1
haqqd tendermint unsafe-reset-all --home $HOME/.haqqd


#!/bin/bash

SNAP_RPC="https://rpc.tm.testedge.haqq.network:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

# persistent_peers
P_PEERS=""

# seed nodes
SEEDS="ddc217640ab137ad6f9cf11fd94fba02eb1e1972@seed1.testedge.haqq.network:26656,7028d26e4d37506b4d5e1f668c945a93693d111b@seed2.testedge.haqq.network:26656,8f7b0add0523ec3648cb48bc12ac35357b1a73ae@195.201.123.87:26656,899eb370da6930cf0bfe01478c82548bb7c71460@34.90.233.163:26656,f2a78c20d5bb567dd05d525b76324a45b5b7aa28@34.90.227.10:26656,4705cf12fb56d7f9eb7144937c9f1b1d8c7b6a4a@34.91.195.139:26656"
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(persistent_peers[[:space:]]+=[[:space:]]+).*$|\1\"$P_PEERS\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"$SEEDS\"|" $HOME/.haqqd/config/config.toml


systemctl restart haqqd

journalctl -fu haqqd -o cat
echo '=============== KURULUM TAMAM! Nodeist Katkılarıyla ==================='
echo '=============== www.NodesWizard.com ==================='
echo -e 'LOGLARI KONTROL ET: \e[1m\e[32mjjournalctl -fu haqqd -o cat\e[0m'
echo -e "SENKRONIZASYONU KONTROL ET: \e[1m\e[32mcurl -s localhost:${HAQQ_PORT}657/status | jq .result.sync_info\e[0m"
