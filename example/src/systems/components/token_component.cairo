#[starknet::component]
pub mod TokenComponent {
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use dojo::world::{IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait};
    
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{
        ERC721Component,
        ERC721Component::{InternalImpl as ERC721InternalImpl},
    };
    use openzeppelin_token::erc721::interface;

    use example::models::store::{
        Store, StoreTrait,
        TokenConfig, TokenConfigStore,
        TokenConfigEntity, TokenConfigEntityStore,
    };

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {}

    mod Errors {
        const CALLER_IS_NOT_MINTER: felt252 = 'TOKEN: caller is not minter';
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +SRC5Component::HasComponent<TContractState>,
        +ERC721Component::ERC721HooksTrait<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        fn initialize(
            ref self: ComponentState<TContractState>,
            minter_contract_address: ContractAddress,
        ) {
            let store: Store = StoreTrait::new(self.get_contract().world());
            let token_config: TokenConfig = TokenConfig{
                token_address: get_contract_address(),
                minter_contract_address,
                minted_count: 0,
            };
            store.set_token_config(@token_config);
        }

        fn can_mint(
            self: @ComponentState<TContractState>,
            caller_address: ContractAddress,
        ) -> bool {
            let store: Store = StoreTrait::new(self.get_contract().world());
            let token_config: TokenConfigEntity = store.get_token_config_entity(get_contract_address());
            (
                token_config.minter_contract_address.is_zero() ||      // anyone can mint
                caller_address == token_config.minter_contract_address // caller is minter contract
            )
        }

        fn mint(
            ref self: ComponentState<TContractState>,
            recipient: ContractAddress,
        ) {
            assert(self.can_mint(get_caller_address()), Errors::CALLER_IS_NOT_MINTER);

            let store: Store = StoreTrait::new(self.get_contract().world());
            let mut token_config: TokenConfigEntity = store.get_token_config_entity(get_contract_address());
            token_config.minted_count += 1;
            store.set_token_config_entity(@token_config);

            // let erc721 = get_dep_component!(self, ERC721);
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.mint(recipient, token_config.minted_count);
        }
    }
}
