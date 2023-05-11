module fungible_tokens::token {
    
    // imports
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin, TreasuryCap};
    use std::option;
    use sui::transfer;

    // our T for the coin
    struct TOKEN has drop {}

    // the init function that takes an OTW
    fun init(witness: TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<TOKEN>(
            witness, // the OTW
            2, //decimals
            b"TOK", // symbol
            b"TOKEN", // coin name
            b"This is a test coin", // description
            option::none(), // icon_url
            ctx,
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<TOKEN>,
        amount: u64,
        recipient_address: address,
        ctx: &mut TxContext,
    ) {
        // create the coins
        // transfer them to recipient address

        coin::mint_and_transfer(
            treasury_cap,
            amount,
            recipient_address,
            ctx,
        );
    }

    public entry fun burn(
        treasury_cap: &mut TreasuryCap<TOKEN>,
        coin: Coin<TOKEN>
    ) {
        coin::burn(treasury_cap, coin);
    }
}