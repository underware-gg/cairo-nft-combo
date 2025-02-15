
// define the interface
#[starknet::interface]
pub trait IActions<TState> {
    fn mint_character(ref self: TState);
    fn cash_faucet(ref self: TState);
}

#[dojo::contract]
pub mod actions {
    // use starknet::{ContractAddress};
    use dojo::world::{WorldStorage};
    use example::libs::store::{Store, StoreTrait};
    use example::libs::dns::{
        DnsTrait,
        ICashDispatcher, ICashDispatcherTrait,
        ICharacterDispatcher, ICharacterDispatcherTrait,
    };

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"example"))
        }
    }

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        fn cash_faucet(ref self: ContractState) {
            let mut store: Store = StoreTrait::new(self.world_default());
            let cash_dispatcher: ICashDispatcher = store.world.cash_dispatcher();
            cash_dispatcher.faucet(starknet::get_caller_address());
        }

        fn mint_character(ref self: ContractState) {
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut character_dispatcher: ICharacterDispatcher = store.world.character_dispatcher();
            character_dispatcher.mint(starknet::get_caller_address());
        }
    }
}
