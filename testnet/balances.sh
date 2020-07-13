#!/bin/bash

sleep 20

lotus wait-api

lotus chain head

export MAIN=$(cat ../localnet2.json | jq -r '.Accounts | .[0] | .Meta .Owner')

export ROOT=$(cat ../localnet2.json | jq -r '.RootKey')

# Send funds to root key
lotus send --source $MAIN $ROOT 5000000

export VERIFIER=$(lotus wallet new)
export CLIENT=$(lotus wallet new)

# Send funds to verifier
lotus send --source $MAIN $VERIFIER 5000000

# Send funds to client
lotus send --source $MAIN $CLIENT 5000000

while [ "5000000 FIL" != "$(lotus wallet balance $ROOT)" ]
do
 sleep 1
 lotus wallet balance $ROOT
done


# lotus-shed verifreg add-verifier t080 100000000000000000000000000000000000000000
# lotus-shed verifreg add-verifier t1fj2s6phuwkn32t3ocilhcpd2vwuu2zdcngdcqhy 100000000000000000000000000000000000000000

lotus-shed verifreg add-verifier --from $ROOT t01001 100000000000000000000000000000000000000000

lotus-shed verifreg list-verifiers

lotus-shed verifreg verify-client --from $VERIFIER $CLIENT 10000000000000000000000000000000000000000

lotus-shed verifreg list-clients

export DATA=$(lotus client import dddd | awk '{print $NF}')

lotus client local

lotus client deal --verified-deal --from $CLIENT $DATA t01000 0.005 100000

while [ "3" != "$(lotus-storage-miner sectors list | wc -l)" ]
do
 sleep 10
 lotus-storage-miner sectors list
done

curl -H "Content-Type: application/json" -H "Authorization: Bearer $(cat ~/.lotusstorage/token)" -d '{"id": 1, "method": "Filecoin.SectorStartSealing", "params": [2]}' localhost:2345/rpc/v0

lotus-storage-miner info

lotus-storage-miner sectors list

while [ "3" != "$(lotus-storage-miner sectors list | grep Proving | wc -l)" ]
do
 sleep 5
 lotus-storage-miner sectors list | tail -n 1
 lotus-storage-miner info | grep "Actual Power"
done

sleep 300000
