#[cfg(test)]
pub mod tester {
    use starknet::{ContractAddress, testing};
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};
    use dojo::model::{ModelStorageTest};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
        WorldStorageTestTrait,
    };

    pub use example::systems::{
        actions::{actions, IActionsDispatcher, IActionsDispatcherTrait},
        character::{character, ICharacterDispatcher, ICharacterDispatcherTrait},
        cash::{cash, ICashDispatcher, ICashDispatcherTrait},
    };
    use example::models::{
        coin_config::{m_CoinConfig},
        tester::{m_Tester, Tester},
    };
    use example::libs::store::{Store, StoreTrait};
    use example::libs::dns::{DnsTrait};

    pub fn ZERO()      -> ContractAddress { starknet::contract_address_const::<0x0>() }
    pub fn OWNER()     -> ContractAddress { starknet::contract_address_const::<0x111>() }
    pub fn OTHER()     -> ContractAddress { starknet::contract_address_const::<0x222>() }
    pub fn RECIPIENT() -> ContractAddress { starknet::contract_address_const::<0x333>() }
    pub fn SPENDER()   -> ContractAddress { starknet::contract_address_const::<0x444>() }

    pub const ETH_TO_WEI: u256 = 1_000_000_000_000_000_000;
    pub fn WEI(eth: u256) -> u256 { eth * ETH_TO_WEI }
    pub fn ETH(wei: u256) -> u256 { wei / ETH_TO_WEI }


    //-------------------------------
    // starknet testing cheats
    // https://github.com/starkware-libs/cairo/blob/main/corelib/src/starknet/testing.cairo
    //

    // set_contract_address : to define the address of the calling contract,
    // set_account_contract_address : to define the address of the account used for the current transaction.
    pub fn impersonate(address: ContractAddress) {
        testing::set_contract_address(address);
        testing::set_account_contract_address(address);
    }
    #[inline(always)]
    pub fn get_block_number() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_number)
    }
    #[inline(always)]
    pub fn get_block_timestamp() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_timestamp)
    }
    #[inline(always)]
    pub fn _next_block() -> (u64, u64) {
        (elapse_block_timestamp(1))
    }
    pub fn elapse_block_timestamp(delta: u64) -> (u64, u64) {
        let new_timestamp = starknet::get_block_timestamp() + delta;
        (set_block_timestamp(new_timestamp))
    }
    pub fn set_block_timestamp(new_timestamp: u64) -> (u64, u64) {
        let new_block_number = get_block_number() + 1;
        testing::set_block_number(new_block_number);
        testing::set_block_timestamp(new_timestamp);
        (new_block_number, new_timestamp)
    }

    // event helpers
    // examples...
    // https://docs.swmansion.com/scarb/corelib/core-starknet-testing-pop_log.html
    // https://github.com/cartridge-gg/arcade/blob/7e3a878192708563082eaf2adfd57f4eec0807fb/packages/achievement/src/tests/test_achievable.cairo#L77-L92
    pub fn pop_log<T, +Drop<T>, +starknet::Event<T>>(address: ContractAddress, event_selector: felt252) -> Option<T> {
        let (mut keys, mut data) = testing::pop_log_raw(address)?;
        let id = keys.pop_front().unwrap(); // Remove the event ID from the keys
        assert_eq!(id, @event_selector, "Wrong event!");
        let ret = starknet::Event::deserialize(ref keys, ref data);
        assert!(data.is_empty(), "Event has extra data (wrong event?)");
        assert!(keys.is_empty(), "Event has extra keys (wrong event?)");
        (ret)
    }
    pub fn assert_no_events_left(address: ContractAddress) {
        assert!(testing::pop_log_raw(address).is_none(), "Events remaining on queue");
    }
    pub fn drop_event(address: ContractAddress) {
        match testing::pop_log_raw(address) {
            core::option::Option::Some(_) => {},
            core::option::Option::None => {},
        };
    }
    pub fn drop_all_events(address: ContractAddress) {
        loop {
            match testing::pop_log_raw(address) {
                core::option::Option::Some(_) => {},
                core::option::Option::None => { break; },
            };
        }
    }


    //-------------------------------
    // Deploy test world
    //

    #[derive(Copy, Drop)]
    pub struct TestSystems {
        pub world: WorldStorage,
        pub store: Store,
        pub actions: IActionsDispatcher,
        pub character: ICharacterDispatcher,
        pub cash: ICashDispatcher,
    }

    #[generate_trait]
    pub impl TestSystemsImpl of TestSystemsTrait {
        #[inline(always)]
        fn from_world(world: WorldStorage) -> TestSystems {
            (TestSystems {
                world,
                store: StoreTrait::new(world),
                actions: world.actions_dispatcher(),
                character: world.character_dispatcher(),
                cash: world.cash_dispatcher(),
            })
        }
    }

    pub fn setup_world(unpause: bool, faucet_amount: u256) -> TestSystems {

        let namespace_def = NamespaceDef {
            namespace: "example",
            resources: [
                // example models
                TestResource::Model(m_CoinConfig::TEST_CLASS_HASH),
                TestResource::Model(m_Tester::TEST_CLASS_HASH),
                // events
                // TestResource::Event(e_CoinConfig::TEST_CLASS_HASH),
                // contracts
                TestResource::Contract(actions::TEST_CLASS_HASH),
                TestResource::Contract(character::TEST_CLASS_HASH),
                TestResource::Contract(cash::TEST_CLASS_HASH),
            ].span(),
        };

        let contract_defs: Span<ContractDef> = array![
            ContractDefTrait::new(@"example", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"example")].span()),
            ContractDefTrait::new(@"example", @"character")
                .with_writer_of([dojo::utils::bytearray_hash(@"example")].span()),
            ContractDefTrait::new(@"example", @"cash")
                // .with_writer_of([selector_from_tag!("example-CoinConfig")].span()),
                .with_writer_of([dojo::utils::bytearray_hash(@"example")].span())
                .with_init_calldata([
                    // 1_000_000_000_000_000_000_000, // faucet_amount: 1,000 Cash
                    faucet_amount.try_into().unwrap(),
                ].span()),
        ].span();

        // setup block
        testing::set_block_number(1);
        testing::set_block_timestamp(1);

        let mut world: WorldStorage = spawn_test_world([namespace_def].span());
        world.sync_perms_and_inits(contract_defs);
        
        // set owner (deployer)
        world.dispatcher.grant_owner(selector_from_tag!("example-actions"), OWNER());
        world.dispatcher.grant_owner(selector_from_tag!("example-character"), OWNER());
        world.dispatcher.grant_owner(selector_from_tag!("example-cash"), OWNER());

        impersonate(OWNER());
        
        if unpause {
            world.character_dispatcher().pause(false);
        }

        (TestSystemsTrait::from_world(world))
    }


    //-------------------------------
    // execute calls
    //

    pub fn set_enable_uri_hooks(ref sys: TestSystems, value: bool) {
        let mut model: Tester = sys.store.get_tester();
        model.enable_uri_hooks = value;
        sys.world.write_model_test(@model);
    }
    
    // ::actions
    pub fn execute_mint_character(system: @IActionsDispatcher, sender: ContractAddress) {
        impersonate(sender);
        (*system).mint_character();
        _next_block();
    }
    pub fn cash_faucet(system: @IActionsDispatcher, sender: ContractAddress) {
        impersonate(sender);
        (*system).cash_faucet();
        _next_block();
    }

}
