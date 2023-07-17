from algosdk.account import generate_account
from algosdk.mnemonic import from_private_key

private, address = generate_account()


print(address)
print("Hello")
print(from_private_key(private))
