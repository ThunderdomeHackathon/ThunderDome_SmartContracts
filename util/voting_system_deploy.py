from algosdk.v2client import algod
from algosdk import account, transaction
from base64 import b64decode
from os import path
from algosdk.v2client.algod import AlgodClient
from os import getenv
from dotenv import load_dotenv

from client import algod_client, AlgodClient
from algosdk.mnemonic import to_private_key

load_dotenv()

def _compile_program(source_code: str, client: AlgodClient = algod_client) -> bytes:
    compile_response = client.compile(source_code)
    return b64decode(compile_response["result"])

# Connect to the Algorand network
algod_client = algod.AlgodClient('', 'https://testnet-api.algonode.network')

# Recover the deployer's account from a mnemonic
deployer_private_key = to_private_key(getenv("MNEMONIC"))
deployer_address = getenv("ACCOUNT_ADDRESS")

# Create the transaction to deploy the smart contract
txn = transaction.ApplicationCreateTxn(
    sender=deployer_address,
    sp=algod_client.suggested_params(),
    on_complete=transaction.OnComplete.NoOpOC,
    approval_program=_compile_program(open("/workspace/AlgorandDevWorkshop/contracts/build/voting_system.teal", "r").read()),
    clear_program=_compile_program(open("/workspace/AlgorandDevWorkshop/contracts/build/clear.teal", "r").read()), 
    global_schema=transaction.StateSchema(2, 0),
    local_schema=transaction.StateSchema(0, 0)
)

# Sign the transaction
signed_txn = txn.sign(deployer_private_key)

# Submit the transaction to the Algorand network
tx_id = algod_client.send_transaction(signed_txn)
print(f"Transaction ID: {tx_id}")

# Wait for the transaction to be confirmed
confirmed_txn = algod_client.pending_transaction_info(tx_id)
while not confirmed_txn.get("confirmed-round"):
    confirmed_txn = algod_client.pending_transaction_info(tx_id)

# Retrieve the contract address
contract_address = confirmed_txn["application-index"]
print(f"Contract Address: {contract_address}")
