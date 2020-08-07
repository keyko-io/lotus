#!/bin/bash

sleep 20

lotus wait-api

lotus chain head

export MAIN=$(cat ../localnet.json | jq -r '.Accounts | .[0] | .Meta .Owner')

export ROOT1=t1vzw5hg23fn7ob4gfpzmzej7h76h6gjr3572elvi # t01001
export ROOT2=t1pnzozdkjnmtmnh6i3ufl7ianvwl2lq7tybazudy # t01002

# Send funds to root key
lotus send --from $MAIN $ROOT1 5000000
lotus send --from $MAIN $ROOT2 5000000

export VERIFIER=t1o4kevzztyeoojfxhessab7phnm5jajgxdlguq5q
export VERIFIER2=$(lotus wallet new)
export CLIENT=$(lotus wallet new)

# Send funds to verifier
lotus send --from $MAIN $VERIFIER 5000000
lotus send --from $MAIN $VERIFIER2 5000000

# Send funds to client
lotus send --from $MAIN $CLIENT 5000000

while [ "5000000 FIL" != "$(lotus wallet balance $ROOT2)" ]
do
 sleep 1
 lotus wallet balance $ROOT2
done


# export PARAM=$(lotus-shed verifreg add-verifier --dry t01003 100000000000000000000000000000000000000000)
# export PARAM2=$(lotus-shed verifreg add-verifier --dry t01004 100000000000000000000000000000000000000000)

lotus msig propose --from $ROOT1 t080 t06 0 2 824300eb0753000125dfa371a19e6f7cb54395ca0000000000
lotus msig inspect t080

node ~/filecoin-verifier-tools/samples/api/approve-verifier.js

sleep 5
lotus-shed verifreg list-verifiers

node ~/filecoin-verifier-tools/samples/api/propose-verifier.js
sleep 5
lotus msig inspect t080
sleep 5
lotus msig inspect t080
lotus msig approve --from $ROOT1 t080 1 $ROOT2 t06 0 2 824300ec0753000125dfa371a19e6f7cb54395ca0000000000

lotus-shed verifreg list-verifiers

# lotus-shed verifreg verify-client --from $VERIFIER $CLIENT 10000000000000000000000000000000000000000

node ~/filecoin-verifier-tools/samples/api/add-client.js $CLIENT
sleep 5
lotus-shed verifreg list-clients

export DATA=$(lotus client import dddd | awk '{print $NF}')

lotus client local

lotus client deal --verified-deal --from $CLIENT $DATA t01000 0.005 100000

while [ "3" != "$(lotus-miner sectors list | wc -l)" ]
do
 sleep 10
 lotus-miner sectors list
done

# hmm
curl -H "Content-Type: application/json" -H "Authorization: Bearer $(cat ~/.lotusstorage/token)" -d '{"id": 1, "method": "Filecoin.SectorStartSealing", "params": [2]}' localhost:2345/rpc/v0

lotus-miner info

lotus-miner sectors list

while [ "3" != "$(lotus-miner sectors list | grep Proving | wc -l)" ]
do
 sleep 5
 lotus-miner sectors list | tail -n 1
 lotus-miner info | grep "Actual Power"
done

sleep 300000
