
export ACCOUNT1=$(lotus wallet new)
export ACCOUNT2=$(lotus wallet new)
export ACCOUNT3=$(lotus wallet new)
export ACCOUNT4=$(lotus wallet new)

export MAIN=$(cat ../localnet2.json | jq -r '.Accounts | .[0] | .Meta .Owner')
export ROOT=$(cat ../localnet2.json | jq -r '.RootKey')

lotus send --source $MAIN $ACCOUNT1 5
lotus send --source $MAIN $ACCOUNT2 5
lotus send --source $MAIN $ACCOUNT3 5
lotus send --source $MAIN $ACCOUNT4 5

while [ "5 FIL" != "$(lotus wallet balance $ACCOUNT1)" ]
do
 sleep 1
 lotus wallet balance $ACCOUNT1
done


# this command should error earlier if no addresses
export RET=$(lotus msig create --from $ACCOUNT1 $ACCOUNT1 $ACCOUNT2 $ACCOUNT3 $ACCOUNT4)

export MSIG_ADDRESS=$(echo $RET | awk '{print $5}')
export MSIG_ACCOUNT=$(echo $RET | awk '{print $4}')

echo "Created address $MSIG_ADDRESS $MSIG_ACCOUNT ($RET)"

lotus wallet balance $MSIG_ADDRESS

lotus-shed verifreg list-verifiers

lotus-shed verifreg set-root --from $ROOT $MSIG_ACCOUNT

export PARAM=$(lotus-shed verifreg add-verifier --dry t01003 100000000000000000000000000000000000000000)

# should error now
lotus-shed verifreg add-verifier --from $ROOT t01003 100000000000000000000000000000000000000000

lotus msig propose --source $ACCOUNT1 $MSIG_ADDRESS t06 0 2 $PARAM
lotus msig inspect $MSIG_ADDRESS

lotus msig approve --source $ACCOUNT2 $MSIG_ADDRESS 0 $ACCOUNT1 t06 0 2 $PARAM
lotus msig approve --source $ACCOUNT3 $MSIG_ADDRESS 0 $ACCOUNT1 t06 0 2 $PARAM
lotus msig approve --source $ACCOUNT4 $MSIG_ADDRESS 0 $ACCOUNT1 t06 0 2 $PARAM

lotus-shed verifreg list-verifiers

