import base64

from base64 import b64decode
from algosdk.v2client import algod
from algosdk import account, transaction
from os import getenv

from dotenv import load_dotenv
from algosdk.mnemonic import to_private_key
from algosdk.v2client.algod import AlgodClient

from algosdk.atomic_transaction_composer import (
    AccountTransactionSigner,
    AtomicTransactionComposer,
    TransactionWithSigner,
)
from algosdk.transaction import (
    ApplicationNoOpTxn,
    AssetOptInTxn,
    PaymentTxn,
    StateSchema,
)

load_dotenv()

def wait_for_confirmation(client, txid):
    last_round = client.status().get("last-round")
    txinfo = client.pending_transaction_info(txid)
    while not (txinfo.get("confirmed-round") and txinfo.get("confirmed-round") > 0):
        print("Waiting for confirmation...")
        last_round += 1
        client.status_after_block(last_round)
        txinfo = client.pending_transaction_info(txid)
    print(
        "Transaction {} confirmed in round {}.".format(
            txid, txinfo.get("confirmed-round")
        )
    )
    return txinfo

# convert 64 bit integer i to byte string
def intToBytes(i):
    return i.to_bytes(8, "big")


# Set the algorand endpoint
algod_client = algod.AlgodClient('', 'https://testnet-api.algonode.network')

# Deployer account details
deployer_private_key = to_private_key(getenv("MNEMONIC"))
deployer_address = getenv("ACCOUNT_ADDRESS")
contract_id = getenv("SMARTCONTRACT_ID")
params = algod_client.suggested_params()


# Test 1 ******************************************************************************************************************************
# *************************************************************************************************************************************

print("Test For Create Election")

app_args = [b"create_election", b"election_1", intToBytes(1689552471), intToBytes(1689723618), intToBytes(10), b'767RGFZOHRS22GIEYUYNAUJFGXI32X6OTRC5PU5ZBGDB3VFRHBDNK24NSM', b'767RGFZOHRS22GIEYUYNAUJFGXI32X6OTRC5PU5ZBGDB3VFRHBDNK24NSM']
txn = transaction.ApplicationNoOpTxn(deployer_address, params, contract_id, app_args)

signed_txn = txn.sign(deployer_private_key)
tx_id = signed_txn.transaction.get_txid()

# Wait for transaction confirmation
algod_client.send_transactions([signed_txn])
wait_for_confirmation(algod_client, tx_id)
