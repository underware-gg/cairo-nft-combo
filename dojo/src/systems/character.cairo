use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait ICharacter<TState> {
    // Dojo
    fn world(self: @TState,) -> IWorldDispatcher;
    fn dojo_resource(ref self: TState) -> felt252;

    // ISRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // IERC721
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // IERC721CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TState, tokenId: u256) -> ContractAddress;
    fn safeTransferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>);
    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256);
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    fn getApproved(self: @TState, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // IERC721Metadata
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    // IERC721MetadataCamelOnly
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;

    // ITokenComponentPublic
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256);
    fn calc_price(self: @TState, recipient: ContractAddress) -> u256;
    fn render_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
trait ITokenComponentPublic<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256);
    fn calc_price(self: @TState, recipient: ContractAddress) -> (ContractAddress, u256);
    fn render_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
trait ITokenComponentInternal<TState> {
}

#[dojo::contract]
mod character {    
    // use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use starknet::{ContractAddress, get_contract_address, get_caller_address, get_block_timestamp};

    // use graffiti::json::JsonImpl;
    // use graffiti::{Tag, TagImpl};

    //-----------------------------------
    // OpenZeppelin start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component};    
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
    }
    //
    // OpenZeppelin end
    //-----------------------------------


    mod Errors {
        const CALLER_IS_NOT_MINTER: felt252     = 'CHARACTER: Caller is not minter';
        const TRANSFER_FAILED: felt252          = 'CHARACTER: Transfer failed';
        const INVALID_CHARACTER: felt252        = 'CHARACTER: Invalid character';
        const NOT_YOUR_CHARACTER: felt252       = 'CHARACTER: Not your character';
    }

    //*******************************
    fn TOKEN_NAME() -> ByteArray {("Sample Character")}
    fn TOKEN_SYMBOL() -> ByteArray {("CHARACTER")}
    fn BASE_URI() -> ByteArray {("https://underware.gg")}
    //*******************************

    fn ZERO() -> ContractAddress {(starknet::contract_address_const::<0x0>())}

    fn dojo_init(
        ref self: ContractState,
    ) {
        self.erc721.initializer(
            TOKEN_NAME(),
            TOKEN_SYMBOL(),
            BASE_URI(),
        );

        // let store: Store = StoreTrait::new(self.world());
        // let token_config: TokenConfig = TokenConfig{
        //     token_address: get_contract_address(),
        //     minter_contract,
        //     renderer_contract,
        //     treasury_contract,
        //     fee_contract,
        //     fee_amount,
        // };
        // store.set_token_config(@token_config);
    }


    //-----------------------------------
    // Public
    //
    use super::{ITokenComponentPublic};
    #[abi(embed_v0)]
    impl TokenComponentPublicImpl of ITokenComponentPublic<ContractState> {
        fn mint(
            ref self: ContractState,
            recipient: ContractAddress,
            token_id: u256,
        ) {
            self.erc721.mint(recipient, token_id);
        }

        fn calc_price(
            self: @ContractState,
            recipient: ContractAddress,
        ) -> (ContractAddress, u256) {
            // if (self.erc721.balance_of(recipient) == 0) {
            //     (ZERO(), 0)
            // } else {
            //     let store = StoreTrait::new(self.world());
            //     let token_config: TokenConfig = store.get_token_config(get_contract_address());
            //     (token_config.fee_contract, token_config.fee_amount)
            // }
            (ZERO(), 0)
        }

        fn render_uri(self: @ContractState, token_id: u256) -> ByteArray {
            format!("{{\"name\":\"{}\"}}", self.erc721._name())
        }
    }

    //-----------------------------------
    // Hooks
    //
    use super::{ICharacterDispatcher, ICharacterDispatcherTrait};
    pub impl ERC721HooksImpl<TContractState> of ERC721Component::ERC721HooksTrait<TContractState> {
        fn before_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
        fn after_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
        fn token_uri(
            self: @ERC721Component::ComponentState<TContractState>,
            base_uri: ByteArray,
            token_id: u256,
        ) -> ByteArray {
            ICharacterDispatcher{
                contract_address: get_contract_address()
            }.render_uri(token_id)
        }
    }

}
