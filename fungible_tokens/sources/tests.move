#[test_only]
module fungible_tokens::token_tests {

    use fungible_tokens::token::{Self, TOKEN};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::test_scenario::{Self};
    use std::debug;

    #[test]
    fun mint_burn() {
        let admin = @0xAAA;

        // start the scenario on a dummy admin address
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        // initialize the token module with the test_init
        {
            token::test_init(test_scenario::ctx(scenario));
        };

        // go to next transaction: mint a Coin<TOKEN> object
        test_scenario::next_tx(scenario, admin);
        {
            let treasuryCap = test_scenario::take_from_sender<TreasuryCap<TOKEN>>(scenario);
            token::mint(&mut treasuryCap, 10, admin, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, treasuryCap);
        };

        // go to next transaction: burn a Coin<TOKEN> object
        test_scenario::next_tx(scenario, admin);
        {
            let coin = test_scenario::take_from_sender<Coin<TOKEN>>(scenario);
            debug::print(&coin);
            let balance = coin::value<TOKEN>(&coin);
            assert!( balance == 10, 1);
            let treasuryCap = test_scenario::take_from_sender<TreasuryCap<TOKEN>>(scenario);
            debug::print(&treasuryCap);
            token::burn(&mut treasuryCap, coin);
            test_scenario::return_to_sender(scenario, treasuryCap);
        };

        // end the scenario
        test_scenario::end(scenario_val);
    }
}