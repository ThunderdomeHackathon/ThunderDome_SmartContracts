from algosdk.v2client import algod
from algosdk import account, transaction

my_address = '767RGFZOHRS22GIEYUYNAUJFGXI32X6OTRC5PU5ZBGDB3VFRHBDNK24NSM'
my_private_key = 'lqZTQvVsvqiOS1+s55mnAGyxtlFQ11yvDwfdm8f62vv/vxMXLjxlrRkExTDQUSU10b1fzpxF19O5CYYd1LE4Rg=='
other_address = 'XIM4HIB7AGOEXNUCS4XSOSDX55AUW6RUHYOBTSMSLZHLLRU43LQ625BK3Q'
other_private_key = '16tKqBhfCCGs2yy4xSUsY0B0TWayXNb6tbLmYczbkeS6GcOgPwGcS7aCly8nSHfvQUt6ND4cGcmSXk61xpza4Q=='

algod_client = algod.AlgodClient('', 'https://testnet-api.algonode.network')
account_info = algod_client.account_info(my_address)
print(account_info)


# tsx = transaction.PaymentTxn(my_address,
#                              algod_client.suggested_params(),
#                              other_address,
#                              250000)

# signed_transaction = tsx.sign(my_private_key)

# transaction_id = algod_client.send_transaction(signed_transaction)

# print(algod_client.pending_transaction_info(transaction_id))

print(algod_client.account_info(other_address))

# just for future referencefrom algosdk import algod, account, encoding
# from algosdk.future.transaction import ApplicationCallTxn

# # Set the Algod API endpoint
# algod_address = "https://<algod-api-address>"
# algod_token = "<algod-api-token>"
# algod_client = algod.AlgodClient(algod_token, algod_address)

# # Sender's account information
# sender_address = "<sender-address>"
# sender_private_key = "<sender-private-key>"

# # Smart contract ID
# contract_id = <smart-contract-id>

# # Get suggested transaction parameters
# params = algod_client.suggested_params()

# # Build the application call transaction
# txn = ApplicationCallTxn(
#     sender=sender_address,
#     sp=params,
#     index=contract_id,
#     on_complete=algosdk.future.transaction.OnComplete.NoOpOC
#     # Add any other parameters required by the contract
# )

# # Sign the transaction
# signed_txn = txn.sign(sender_private_key)

# # Submit the transaction to the network
# tx_id = algod_client.send_transaction(signed_txn)

# # Wait for transaction confirmation
# algod_client.status_after_block(tx_id)

# # Retrieve the transaction details
# tx_details = algod_client.pending_transaction_info(tx_id)
# print("Transaction details:", tx_details)