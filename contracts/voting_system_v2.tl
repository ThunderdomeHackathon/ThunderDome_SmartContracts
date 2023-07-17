#pragma version 8

# Create election method
# - election_id
# - start_time
# - end_time
# - Number of voters
# - addresses for each voter in election


# Backend intergration
# call a function that creates a algorand client (voter and candidate)
# call a function that transfers funds into the algorand client
# Make a create election call to smart contract with all required parameters
# Make a transfer asset transaction from the voter to the candidate when vote is cast
# extract the number of assets each candidate account has

# This smart contract creates and sells vote assets.
# Global state schema: 1 uints, 0 bytes
# Local state schema: 0 uints, 0 bytes

# Election Details Box
struct ElectionDetails:
    start_timestamp: int
    end_timestamp: int
end

# Global state keys
const bytes ELECTIONS_CREATED = "elections_created"
const bytes CURRENT_ELECTION_ID = "current_election_id"
const bytes CURRENT_VOTE_ASSET_ID = "current_vote_id"

if Txn.ApplicationID == 0:
    app_global_put(ELECTIONS_CREATED, 0)
    exit(1)
end

switch Txn.OnCompletion:
    NoOp: main
    OptIn: opt_in
    CloseOut: close_out
    UpdateApplication: update_app
    DeleteApplication: delete_app
end

block opt_in:
    exit(0)
end

block close_out:
    exit(0)
end

block update_app:
    exit(0)
end

block delete_app:
    exit(0)
end

block main:
    # Route to the correct block of code based on the first argument
    switch Txn.ApplicationArgs[0]:
        "create_election": create_election
        "cast_vote": cast_vote
    end

    block create_election:

        # Extract election variables
        bytes election_id = Txn.ApplicationArgs[1]
        int start_timestamp = btoi(Txn.ApplicationArgs[2])
        int end_timestamp = btoi(Txn.ApplicationArgs[3])
        int number_of_voters = btoi(Txn.ApplicationArgs[4])

        # Create vote ASA (Asset)
        inner_txn:
            TypeEnum: Acfg
            Sender: Global.CurrentApplicationAddress
            ConfigAssetTotal: 2
            ConfigAssetDecimals: 0
            ConfigAssetDefaultFrozen: 0
            ConfigAssetUnitName: "Vote"
            ConfigAssetName: "Vote"
            ConfigAssetManager: Global.CurrentApplicationAddress
            Fee: 0
        end

        # Send each registered voter a single vote asset
        send_vote_asset(Txn.ApplicationArgs[4], Itxn.CreatedAssetID)
        send_vote_asset(Txn.ApplicationArgs[5], Itxn.CreatedAssetID)

        # Store election data in a box
        box<ElectionDetails> election = CreateBox(election_id)
        election.start_timestamp = start_timestamp
        election.end_timestamp = end_timestamp

        # Update global state
        app_global_put(CURRENT_VOTE_ASSET_ID, Itxn.CreatedAssetID)
        app_global_put(CURRENT_ELECTION_ID, election_id)
        app_global_put(ELECTIONS_CREATED, (app_global_get(ELECTIONS_CREATED) + 1))

        # Log the ticket ID
        log(itob(Itxn.CreatedAssetID))

        exit(1)
    end

    block cast_vote:
        # Get the vote transaction information
        bytes election_id = Txn.ApplicationArgs[1]
        bytes assetreceiver = Txn.ApplicationArgs[2]
        int ticket_id = btoi(Txn.ApplicationArgs[3])
        
        box<ElectionDetails> election = OpenBox(election_id)

        # Setting up timing limitations
        assert((Global.LatestTimestamp < election.end_timestamp) && (Global.LatestTimestamp > election.start_timestamp))

        # Send ticket(s)
        inner_txn:
            TypeEnum: Axfer
            Sender: Txn.Sender
            XferAsset: ticket_id
            AssetAmount: 1
            AssetReceiver: assetreceiver
            Fee: 0
        end

        exit(1)
    end
end

func send_vote_asset(reciever_id: bytes, asset_id: int):
    # Send ticket(s)
        inner_txn:
            TypeEnum: Axfer
            Sender: Global.CurrentApplicationAddress
            XferAsset: asset_id
            AssetAmount: 1
            AssetReceiver: reciever_id
            Fee: 0
        end
    return
end
