#[allow(unused_const)]
module nft_project::MyNFT { 

    //Imports
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::url::{Self, Url};
    use sui::tx_context::{Self, TxContext}; 

    ///Constants 
    const MAX_SUPPLY: u64 = 10;
    const ELimitExceeded: u64 = 1;

    /// NFT Structure
    struct NFT has key, store {
        id: UID, 
        n: u64, 
        url: Url 
    }

    /// Minting Capability Structure
    /// main role of this struct is to put limits of NFT creation.
    struct MintCap has key { 
        id: UID, 
        number_issued: u64, 
        }


    /// Initializes the minting capability
    ///
    /// This function creates a new MintCap object and transfers it to the sender
    fun init(ctx: &mut TxContext) { 
        let minting_cap = MintCap { id: object::new(ctx), number_issued: 0, }; 
        transfer::transfer(minting_cap, tx_context::sender(ctx)) 
        }


    /// This function mints a new NFT if the issued count is within the MAX_SUPPLY.
    /// It increments the issued counter, creates a new NFT object, and transfers it to the specified receiver.
    public entry fun mint(cap: &mut MintCap, url: vector<u8>, receiver: address, ctx: &mut TxContext) {

      let n = cap.number_issued; 
      cap.number_issued = n + 1;

      //ensure the amount minted is less than the MAX_SUPPLY (prevent overminting)
      assert!(n <= MAX_SUPPLY, ELimitExceeded);

      let nft = NFT { id: object::new(ctx), n: n, url: url::new_unsafe_from_bytes(url) }; 

      transfer::transfer(nft, receiver); 
      } 
    }


    //Instructions to use:

    //1. $ sui move build

    //2. $ sui client transfer --object-id {YOUR_MintCap_ID} --to {YOUR_WALLET_ADDRESS} --gas-budget 100000000
    //^ use the first obj created

    //3. $ sui client call --function mint --module MyNFT --package {YOUR_PACKAGE_ID} --args {YOUR_MINTCAP_ID} {IMAGE_URL} {RECEIVER_ADDRESS} --gas-budget 100000000



//Personal Notes:
//  TxContext - transaction content

// key - allows struct to be used as a global storage resource, unique id
// store - ability to be persisted across transactions
// uid -- unique identifier for objects on the sui blockchain
