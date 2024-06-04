#[allow(unused_const)]
module tokens::MyToken { 

    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Contract Address
    const CONTRACT_ADDRESS: address = @0x1; // replace this with the actual contract address

    /// NFT structure that can be minted
    struct MyToken has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
        balance: u64,
    }

    // Events:
    struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        name: string::String,
    }

    /// Create a new devnet_nft
    public fun mint_to_sender(name: vector<u8>, description: vector<u8>, url: vector<u8>, balance: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let nft = MyToken {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            balance: balance,
        };

        event::emit(NFTMinted { object_id: object::id(&nft),creator: sender, name: nft.name,});

        transfer::public_transfer(nft, sender);
    }

    /// Transfer NFT to Recipient. Ensures:
    /// (1) the contract itself can transfer it to any address
    /// (2) users are ONLY allowed to transfer it back to the contract
    public fun transfer(nft: MyToken, recipient: address, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        if (sender != CONTRACT_ADDRESS) {
            assert!(recipient == CONTRACT_ADDRESS, 0x1);
        }
        transfer::public_transfer(nft, recipient);
    }

    //add balance
    public fun modify_balance(nft: &mut MyToken, new_balance: u64){
        assert!(new_balance >= 0, 42);
        nft.balance = new_balance;
    }

}

