module simple_game::swords {

    // Imports
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::test_scenario;

    // Error codes
    const ESenderIsRecipient: u64 = 2;

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

    // the mint and transfer sword function
    // only the forge owner should be able to call this function
    public fun mint_transfer_sword(
        forge: &mut Forge,
        magic: u64,
        strength: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(tx_context::sender(ctx) != recipient, ESenderIsRecipient);
        let new_sword = Sword {
            id: object::new(ctx),
            magic,
            strength,
        };
        forge.swords_created = forge.swords_created + 1;
        transfer::public_transfer(new_sword, recipient);
    }

    public fun transfer_sword(sword: Sword, recipient: address) {
        transfer::public_transfer(sword, recipient);
    }

    #[test]
    public fun test_init() {
        let admin = @0xAAAA;
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        // initialize the module
        {
            init(test_scenario::ctx(scenario));
        };

        // test that admin got the forge object
        test_scenario::next_tx(scenario, admin);
        {
            let forge = test_scenario::take_from_sender<Forge>(scenario);
            assert!(forge.swords_created == 0, 1);
            test_scenario::return_to_sender(scenario, forge);            
        };

        // end the scenario
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_mint_transfer_sword() {
        let admin = @0xAAAA;
        let sword_owner = @0xBBBB;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        {
            init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, admin);
        {
            let forge = test_scenario::take_from_sender<Forge>(scenario);
            mint_transfer_sword(
                &mut forge,
                17,
                42,
                sword_owner,
                test_scenario::ctx(scenario),
            );
            assert!(forge.swords_created == 1, 2);
            test_scenario::return_to_sender(scenario, forge);
        };

        test_scenario::next_tx(scenario, sword_owner);
        {
            let sword = test_scenario::take_from_sender<Sword>(scenario);
            assert!(sword.magic == 17 && sword.strength == 42, 1);
            test_scenario::return_to_sender(scenario, sword);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_transfer_sword() {
        let admin = @0xAAAA;
        let initial_owner = @0xBBBB;
        let final_owner = @0xCCCC;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // initialize the module
        {
            init(test_scenario::ctx(scenario));
        };

        // mint a sword and transfer it to the initial owner
        test_scenario::next_tx(scenario, admin);
        {
            let magic: u64 = 17;
            let strength: u64 = 42;
            let forge = test_scenario::take_from_sender<Forge>(scenario);
            mint_transfer_sword(
                &mut forge,
                magic,
                strength,
                initial_owner,
                test_scenario::ctx(scenario),
            );
            assert!(forge.swords_created == 1, 2);
            test_scenario::return_to_sender(scenario, forge);
        };

        // transfer the sword to the final owner
        test_scenario::next_tx(scenario, initial_owner);
        {
            let sword = test_scenario::take_from_sender<Sword>(scenario);
            transfer_sword(sword, final_owner);
        };

        // take it from the final owner and check some properties
        test_scenario::next_tx(scenario, final_owner);
        {
            let sword = test_scenario::take_from_sender<Sword>(scenario);
            assert!(sword.magic == 17, 1);
            assert!(sword.strength == 42, 2);
            test_scenario::return_to_sender(scenario, sword);
        };

        test_scenario::end(scenario_val);
    }
}