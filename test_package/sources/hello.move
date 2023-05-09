module test_package::hello {
    // contents of module named "hello"

    // let's import some modules and some of their functions
    // from the standard library package
    use std::string;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // the basic struct that we will be using from now on
    struct TestObject has key, store {
        id: UID,
        text: string::String,
    }

    // just a dummy function for testing
    public fun add(x: u64, u: u64): u64 {
        x + u
    }

    // the function to create a new object and transfer it to the caller
    public entry fun mint(ctx: &mut TxContext) {
        // create a new object
        let object = TestObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello web3 world!!"),
        };
        // transfer it to the transaction caller (sender)
        transfer::transfer(object, tx_context::sender(ctx));
    }

    /*
        !really interesting!
        after calling the mint function from the outside world, two objects are affected:
        1. created: a new TestObject
        2. modified: the caller's balance object
    */
}