#pragma version 8

# By Praise Jaravani

# This smart contract hosts blockchain backed elections for a voting system app.
# Global state schema: 2 uints, 0 bytes
# Local state schema: 0 uints, 0 bytes

# Data Storage Overview:
# Elections will be created and stored in box's with the election data.
# Boxs will then be created for each voter who casts a vote with the specific election_id and voter number as a key

# The VoterKey struct will be the key for the boxes storing the voter information
struct VoterKey:
    election_id: bytes[32]
    vote_num: int
end

# The CandidateKey struct will be the key for the boxes storing the candidate information
struct CandidateKey:
    election_id: bytes[32]
    candidate_id: int
end

# Election MBR:
# Box size: 24 bytes
# Key size: 36 bytes
# MBR: 26500 = 2500 + 400 * (box size + key size) = 2500 + 400 * (24 + 36)

# Voter MBR:
# Box size: 36 bytes
# Key size: 44 bytes
# MBR: 34500 = 2500 + 400 * (box size + key size) = 2500 + 400 * (36 + 44)

# Candidate MBR:
# Box size: 8 bytes
# Key size: 72 bytes
# MBR: 34500 = 2500 + 400 * (box size + key size) = 2500 + 400 * (72 + 8)

# This struct will be the value for the box storing the election details
struct ElectionValue:
    start_timestamp: int
    end_timestamp: int
    maximum_vote_num: int
end

# This struct will be the value for the box storing the voter details
struct VoterValue:
    otp: bytes[32]
    creator: bytes[32]
end

# The CandidateKey struct will be the value for the boxes storing the candidate information
struct CandidateValue:
    number_of_votes: int
end

# Global state keys
const bytes G_ELECTIONS_CREATED = "elections_created"

# Methods
const bytes CREATE_ELECTION = "create_election"
const bytes MAKE_VOTE = "make_vote"
const bytes REGISTER_VOTER = "register_voter"

# Constants
# Box MBR + asset opt-in MBR = 28100 + 100,000 + 21700
const int ELECTION_MBR_AMOUNT = 26500
const int VOTER_MBR_AMOUNT = 34500
const int CANDIDATE_MBR_AMOUNT = 34500

# Constructor of the smart contract
if Txn.ApplicationID == 0:
    app_global_put(G_ELECTIONS_CREATED, 0)
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
    switch Txn.ApplicationArgs[0]:
        CREATE_ELECTION: create_election
        MAKE_VOTE: make_vote
        REGISTER_VOTER: register_voter
    end

    block create_election:
        if Txn.Sender != Global.CurrentApplicationAddress:
            # Sender pays for the MBR of the boxes required to store election and candidate details if they are not the owner of the smart contract
            assert(Gtxn[-1].TypeEnum == Pay)
            assert(Gtxn[-1].Sender == Txn.Sender)
            assert(Gtxn[-1].Receiver == Global.CurrentApplicationAddress)
            assert(Gtxn[-1].Amount == ELECTION_MBR_AMOUNT)
        end

        # Initialise the key for the election
        # Parameter 1: election_id
        # Create election box key
        bytes election_id = Txn.ApplicationArgs[1]

        # Create a Box for the current election
        # Parameter 2: election start_timestamp
        # Parameter 3: election end_timestamp
        box<ElectionValue> election = CreateBox(election_id)
        election.start_timestamp = btoi(Txn.ApplicationArgs[2])
        election.end_timestamp = btoi(Txn.ApplicationArgs[3])
        election.maximum_vote_num = 0

        # Create boxes for candidates in current election
        # Maximum 5 candidates per election
        # Parameter 4 to 8: Candidate 1 to 10 ID numbers
        create_candidate(election_id,btoi(Txn.ApplicationArgs[4]))
        create_candidate(election_id,btoi(Txn.ApplicationArgs[5]))
        create_candidate(election_id,btoi(Txn.ApplicationArgs[6]))
        create_candidate(election_id,btoi(Txn.ApplicationArgs[7]))
        create_candidate(election_id,btoi(Txn.ApplicationArgs[8]))
        
        # Update both local and global variables
        app_global_put(G_ELECTIONS_CREATED, (app_global_get(G_ELECTIONS_CREATED) + 1))


        exit(1)
    end

    block make_vote:
        # Parameter 1: election_id
        bytes election_id = Txn.ApplicationArgs[1]
        box<ElectionValue> election = OpenBox(election_id)

        # Setting up timing limitations
        assert((Global.LatestTimestamp < election.end_timestamp) && (Global.LatestTimestamp > election.start_timestamp))

        # Parameter 2: regular key for voter attempting to vote
        bytes hashed_key = sha256(Txn.ApplicationArgs[2])
        int approval_flag = 0

        # Open registered vote boxes
        int start = 0
        int finish = election.maximum_vote_num

        # Check to see if any of the boxes have matching hashedkeys
        # If they do, delete the box and return the funds used to create it.
        for x in start:finish:
            VoterKey key = bzero(44)
            key.election_id = election_id
            key.vote_num = x 

            box<VoterValue> vote = OpenBox(key)
            if vote.otp == hashed_key:
                approval_flag = 1
                    if vote.creator != Global.CurrentApplicationAddress:
                        # Pay seller back the MBR increase from the auction
                        inner_txn:
                            TypeEnum: Pay
                            Sender: Global.CurrentApplicationAddress
                            Receiver: vote.creator
                            Amount: VOTER_MBR_AMOUNT
                            Fee: 0
                        end
                    end
                int existed = box_del(key)
            end
        end

        assert(approval_flag == 1)

        # Casting the vote
        # Parameter 3: candidate_id of the candidate being voted for
        int candidate_id = btoi(Txn.ApplicationArgs[3])

        CandidateKey key1 = bzero(72)
        key1.election_id = election_id
        key1.candidate_id = candidate_id

        box<CandidateValue> candidate = OpenBox(key1)
        candidate.number_of_votes = candidate.number_of_votes + 1

        exit(1)
    
    end

    block register_voter:
        if Txn.Sender != Global.CurrentApplicationAddress:
            # Sender pays for the MBR of their box
            int price = VOTER_MBR_AMOUNT * btoi(Txn.ApplicationArgs[2])
            assert(Gtxn[-1].TypeEnum == Pay)
            assert(Gtxn[-1].Sender == Txn.Sender)
            assert(Gtxn[-1].Receiver == Global.CurrentApplicationAddress)
            assert(Gtxn[-1].Amount == price)
        end

        # Parameter 1: election_id
        bytes election_id = Txn.ApplicationArgs[1]
        box<ElectionValue> election = OpenBox(election_id)

        # When a user registers, they pass in a hashed secret key that is stored globally by the smart contract.
        # This key is used to autheticate them when passing a vote

        # Maximum 20 Voters per election
        # Parameter 2 to 22: list of hashed keys being stored
        create_voter(election_id, election.maximum_vote_num, btoi(Txn.ApplicationArgs[2]),Txn.Sender)
        election.maximum_vote_num = election.maximum_vote_num + 1
        create_voter(election_id, election.maximum_vote_num, btoi(Txn.ApplicationArgs[3]),Txn.Sender)
        election.maximum_vote_num = election.maximum_vote_num + 1
        create_voter(election_id, election.maximum_vote_num, btoi(Txn.ApplicationArgs[4]),Txn.Sender)
        election.maximum_vote_num = election.maximum_vote_num + 1
        create_voter(election_id, election.maximum_vote_num, btoi(Txn.ApplicationArgs[5]),Txn.Sender)
        election.maximum_vote_num = election.maximum_vote_num + 1
        create_voter(election_id, election.maximum_vote_num, btoi(Txn.ApplicationArgs[6]),Txn.Sender)
        election.maximum_vote_num = election.maximum_vote_num + 1

        exit(1)
    end
end

# creates a box for a candidate that initialises that candidates voter count to zero.
func create_candidate(election_id: bytes, candidate_id: int):
    CandidateKey key = bzero(40)
    key.election_id = election_id
    key.candidate_id = candidate_id

    box<CandidateValue> candidate = CreateBox(key)
    candidate.number_of_votes = 0
    return 
end

# creates a box for each voter in a particular election which stores their one time hashedkey for authentication when voting
func create_voter(election_id: bytes, vote_num: int, hashed_key: bytes[32], creator: bytes[32]):
    # Create vote box key
    VoterKey key = bzero(40)
    key.election_id = election_id
    key.vote_num = vote_num

    # Create vote box that will store the vote
    box<VoterValue> vote = CreateBox(key)
    vote.otp = hashed_key
    vote.creator = creator
    return
end

# Done!

