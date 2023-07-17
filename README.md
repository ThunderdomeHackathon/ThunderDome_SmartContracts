# Project Smart Contracts

This repository contains the smart contracts developed for the Project Smart Contracts. Two different smart contracts were written and deployed for this project: `voting_system.tl` and `voting_system_v2.tl`.

## `voting_system.tl`

- **app_id**: 258474216
- **Implementation Method**: Used boxes to store election details on the app, candidate details, and voter details. Votes were cast by incrementing the count in each candidate box.
- **Source Code**: `contracts/voting_system.tl`

## `voting_system_v2.tl`

- **app_id**: 258473431
- **Implementation Method**: Created a vote asset for each election, then transferred the vote asset from the voter to the candidate account during the election to make a vote.
- **Source Code**: `contracts/voting_system_v2.tl`

## Final Implementation for Hackathon

The final implementation for the hackathon involved a version 2 style implementation. It made calls to the testnet from the backend to create vote assets and transfer them between custodial accounts for voting. The code for this implementation can be found in the Thunderdome Backend repository under `blockchain_client/`. Our next step, as discussed in our pitch deck, would be to use the `voting_system_v2` smart contract to create an engine for voting on the blockchain ledger.

## Deployment

The deployment of the smart contracts was done using the script `util/voting_system_deploy.py`. This script was used to deploy the smart contracts and set up the necessary configurations.

## Languages and Dependencies

The smart contracts were written using **Tealish**, a programming language for writing smart contracts on the Algorand blockchain. The Tealish code was compiled to Teal bytecode and deployed and called using the **AlgoSDK** functions.

Dependencies:
- Tealish
- AlgoSDK
