module simple_game::swords {

    // Imports
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    // Structs
    struct Sword has key, store {
        id: UID,
        strength: u64,
        magic: u64,
    }

    struct Forge has key, store {
        id: UID,
        swords_created: u64,
    }

    // Module initializer

    /// creates a Forge struct and sends it to the transaction sender
    /// i.e. to the package publisher
    fun init(ctx: &mut TxContext) {
        let admin = Forge {
            id: object::new(ctx),
            swords_created: 0,
        };

        transfer::public_transfer(admin, tx_context::sender(ctx));
    }

    // Accessors
    public fun magic(self: &Sword): u64 {
        self.magic
    }

    public fun strength(self: &Sword): u64 {
        self.strength
    }

    public fun swords_created(self: &Forge): u64 {
        self.swords_created
    }
}