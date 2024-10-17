use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
pub trait ICharacter<TState> {
    // IWorldProvider
    fn world(self: @TState,) -> IWorldDispatcher;

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

    // ITokenPublic
    fn mint(ref self: TState, recipient: ContractAddress);
    fn render_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
pub trait ITokenPublic<TState> {
    fn mint(ref self: TState, recipient: ContractAddress);
    fn render_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
pub trait ITokenComponentInternal<TState> {
}

#[dojo::contract]
pub mod character {    
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
    use oz_token::systems::components::erc721_hooks::{ERC721HooksImpl};
    use oz_token::systems::components::token_component::{TokenComponent};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: TokenComponent, storage: token, event: TokenEvent);
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl TokenInternalImpl = TokenComponent::InternalImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        token: TokenComponent::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        TokenEvent: TokenComponent::Event,
    }
    //
    // OpenZeppelin end
    //-----------------------------------


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
        self.token.initialize(ZERO());
    }


    //-----------------------------------
    // Public
    //
    use super::{ITokenPublic};
    #[abi(embed_v0)]
    impl TokenComponentPublicImpl of ITokenPublic<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress) {
            self.token.mint(recipient);
        }

        fn render_uri(self: @ContractState, token_id: u256) -> ByteArray {
            format!("{{\"name\":\"{}\"}}", self.erc721._name())
        }
    }

}
