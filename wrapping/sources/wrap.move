module wrapping::wrap {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;

    // custom error codes
    const ENotIntendedAddress: u64 = 1;

    struct TeacherCap has key {
        id: UID,
    }

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

    struct TeacherAddedEvent has copy, drop {
        requester: address,
        new_teacher_address: address,
    }

    fun init(ctx: &mut TxContext) {
        let teacherCap = TeacherCap {
            id: object::new(ctx)
        };
        transfer::transfer(teacherCap, tx_context::sender(ctx));
    }

    public entry fun create_wrappable_transcript_object(
        _: &TeacherCap,
        history: u8,
        math: u8,
        literature: u8,
        ctx: &mut TxContext,
    ) {
        let wrappableTranscript = WrappableTranscript {
            id: object::new(ctx),
            history,
            math,
            literature   
        };
        transfer::transfer(wrappableTranscript, tx_context::sender(ctx));
    }

    public entry fun request_transcript(
        transcript: WrappableTranscript,
        intended_address: address,
        ctx: &mut TxContext
    ) {
        let folderObject = Folder {
            id: object::new(ctx),
            transcript,
            intended_address,
        };
        transfer::transfer(folderObject, intended_address);
    }

    public entry fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
        // check that the ts sender is the intended address of the folder
        assert!(folder.intended_address == tx_context::sender(ctx), ENotIntendedAddress);
        // unpack the transcript from inside the folder
        let Folder {
            id,
            transcript,
            intended_address: _,
        } = folder;        
        // send the transcript to the intended address of the folder
        transfer::transfer(transcript, tx_context::sender(ctx));
        // delete the folder
        object::delete(id);
    }

    // attention, this way each teacher can add a new teacher
    // if we wanted only let's say the adminTeacher to be able to add a new teacher
    // new Cap => TeacherAdminCap
    public entry fun add_new_teacher(
        _: &TeacherCap,
        new_teacher_address: address,
        ctx: &mut TxContext,
    ) {
        let teacherCap = TeacherCap {
            id: object::new(ctx),
        };
        let teacherAddedEvent = TeacherAddedEvent {
            requester: tx_context::sender(ctx),
            new_teacher_address,
        };
        event::emit(teacherAddedEvent);
        transfer::transfer(teacherCap, tx_context::sender(ctx));
    }
}