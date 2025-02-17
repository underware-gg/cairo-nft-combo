use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
pub trait ICharacter<TState> {
    // IWorldProvider
    fn world(self: @TState,) -> IWorldDispatcher;

    //-----------------------------------
    // IERC721ComboABI
    // (ISRC5)
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // (IERC721)
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (IERC721CamelOnly)
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TState, tokenId: u256) -> ContractAddress;
    fn safeTransferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>);
    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256);
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    fn getApproved(self: @TState, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (IERC721Metadata)
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    // (IERC721MetadataCamelOnly)
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    fn contractURI(self: @TState) -> ByteArray;
    fn contract_uri_updated(ref self: TState);
    //-----------------------------------
    // IERC4906MetadataUpdate
    fn metadata_update(ref self: TState, token_id: u256);
    fn batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);


    //-----------------------------------
    // ITokenComponentPublic
    //
    fn minted_count(self: @TState) -> u128;
    fn can_mint(self: @TState, recipient: ContractAddress) -> bool;
    fn exists(self: @TState, token_id: u128) -> bool;
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u128) -> bool;

    //-----------------------------------
    // ICharacterPublic
    //
    fn mint(ref self: TState, recipient: ContractAddress);
    // ICharacterProtected
    fn render_token_uri(self: @TState, token_id: u256) -> Option<ByteArray>;
    fn render_contract_uri(self: @TState) -> Option<ByteArray>;
}

// Exposed to Cartridge Controller
#[starknet::interface]
pub trait ICharacterPublic<TState> {
    fn mint(ref self: TState, recipient: ContractAddress);
}

// Exposed to world only
#[starknet::interface]
pub trait ICharacterProtected<TState> {
    fn render_token_uri(self: @TState, token_id: u256) -> Option<ByteArray>;
    fn render_contract_uri(self: @TState) -> Option<ByteArray>;
}

#[dojo::contract]
pub mod character {
    use starknet::{ContractAddress};
    use dojo::world::{WorldStorage};

    //-----------------------------------
    // OpenZeppelin start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component};
    use openzeppelin_token::erc721::ERC721HooksEmptyImpl;
    use nft_combo::erc721::erc721_combo::{ERC721ComboComponent};
    use example::systems::components::token_component::{TokenComponent};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);
    component!(path: TokenComponent, storage: token, event: TokenEvent);
    // #[abi(embed_v0)]
    // impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl TokenComponentPublicImpl = TokenComponent::TokenComponentPublicImpl<ContractState>;
    impl TokenInternalImpl = TokenComponent::InternalImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_combo: ERC721ComboComponent::Storage,
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
        ERC721ComboEvent: ERC721ComboComponent::Event,
        #[flat]
        TokenEvent: TokenComponent::Event,
    }
    //
    // OpenZeppelin end
    //-----------------------------------

    use example::libs::dns::{DnsTrait};
    use example::libs::store::{Store, StoreTrait};
    use example::models::tester::{Tester};


    //*******************************
    fn TOKEN_NAME() -> ByteArray {("Sample Character")}
    fn TOKEN_SYMBOL() -> ByteArray {("CHARACTER")}
    fn BASE_URI() -> ByteArray {("https://underware.gg/token/")}
    fn CONTRACT_URI() -> ByteArray {("https://underware.gg/contract.json")}
    //*******************************

    fn ZERO() -> ContractAddress {(starknet::contract_address_const::<0x0>())}

    fn dojo_init(
        ref self: ContractState,
    ) {
        let mut world = self.world_default();
        self.erc721_combo.initializer(
            TOKEN_NAME(),
            TOKEN_SYMBOL(),
            BASE_URI(),
            CONTRACT_URI(),
        );
        self.token.initialize(
            world.actions_address(),
        );
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"example"))
        }
    }


    //-----------------------------------
    // Public
    //
    #[abi(embed_v0)]
    impl CharacterPublicImpl of super::ICharacterPublic<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress) {
            self.token.mint(recipient);
        }
    }

    //-----------------------------------
    // Protected
    //
    #[abi(embed_v0)]
    impl CharacterProtectedImpl of super::ICharacterProtected<ContractState> {
        fn render_token_uri(self: @ContractState, token_id: u256) -> Option<ByteArray> {
            let mut store: Store = StoreTrait::new(self.world_default());
            let tester: Tester = store.get_tester();
            (match tester.skip_uri_hooks {
                true => { Option::None },
                false => { Option::Some(format!("{{\"name\":\"{} #{}\"}}", self.name(), token_id)) },
            })
        }
        fn render_contract_uri(self: @ContractState) -> Option<ByteArray> {
            let mut store: Store = StoreTrait::new(self.world_default());
            let tester: Tester = store.get_tester();
            (match tester.skip_uri_hooks {
                true => { Option::None },
                false => { Option::Some(format!("{{\"name\":\"{} ERC-721 token\"}}", self.name())) },
            })
        }
    }


    //-----------------------------------
    // ERC721HooksTrait
    //
    pub impl ERC721HooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
        fn token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<ByteArray> {
            (self.get_contract().render_token_uri(token_id))
        }
        fn contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState> ) -> Option<ByteArray> {
            (self.get_contract().render_contract_uri())
        }
    }

}
