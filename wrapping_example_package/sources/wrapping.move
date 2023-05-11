module wrapping_example_package::wrapping {
    // contents of 
    // package: wrapping_example_package
    // module: wrapping

    // import the modules we are gonna need
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{TxContext};

    struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    struct Folder has key {
        id: UID,
        transcript: WrappableTranscript,
        intended_address: address,
    }

    public entry fun request_transcript(
        transcript: WrappableTranscript,
        intended_address: address,
        ctx: &mut TxContext,
    ) {
        let folderObject = Folder {
            id: object::new(ctx),
            transcript,
            intended_address,
        };
        transfer::transfer(folderObject, intended_address);
    }
}