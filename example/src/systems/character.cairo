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
    // (CamelOnly)
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
    // (CamelOnly)
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    //-----------------------------------
    // IERC721Minter
    fn max_supply(self: @TState) -> u256;
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
    fn is_minting_paused(self: @TState) -> bool;
    // (CamelOnly)
    fn maxSupply(self: @TState) -> u256;
    fn totalSupply(self: @TState) -> u256;
    fn lastTokenId(self: @TState) -> u256;
    fn isMintingPaused(self: @TState) -> bool;
    //-----------------------------------
    // IERC4906MetadataUpdate
    fn emit_metadata_update(ref self: TState, token_id: u256);
    fn emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    fn emit_contract_uri_updated(ref self: TState);
    // (CamelOnly)
    fn contractURI(self: @TState) -> ByteArray;
    //-----------------------------------
    // IERC2981RoyaltyInfo
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // (CamelOnly)
    fn royaltyInfo(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn defaultRoyalty(self: @TState) -> (ContractAddress, u128, u128);
    fn tokenRoyalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);

    //-----------------------------------
    // ICharacterPublic
    //
    fn mint(ref self: TState, recipient: ContractAddress);
    fn burn(ref self: TState, token_id: u128);
    fn pause(ref self: TState, paused: bool);
    // ICharacterProtected
    fn render_token_uri(self: @TState, token_id: u256) -> Option<ByteArray>;
    fn render_contract_uri(self: @TState) -> Option<ByteArray>;
}

// Exposed to Cartridge Controller
#[starknet::interface]
pub trait ICharacterPublic<TState> {
    fn mint(ref self: TState, recipient: ContractAddress);
    fn burn(ref self: TState, token_id: u128);
    fn pause(ref self: TState, paused: bool);
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
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};

    //-----------------------------------
    // OpenZeppelin start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component};
    use nft_combo::erc721::erc721_combo::{ERC721ComboComponent, ERC721ComboComponent::ERC721HooksImpl};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);
    // #[abi(embed_v0)]
    // impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_combo: ERC721ComboComponent::Storage,
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
    }
    //
    // OpenZeppelin end
    //-----------------------------------

    // use example::libs::dns::{DnsTrait};
    use example::libs::store::{Store, StoreTrait};
    use example::models::tester::{Tester};

    pub mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252 = 'CHARACTER: caller is not owner';
    }


    //*************************************
    // token defaults
    //
    pub fn TOKEN_NAME()     -> ByteArray {("Sample Character")}
    pub fn TOKEN_SYMBOL()   -> ByteArray {("CHARACTER")}
    pub fn BASE_URI()       -> ByteArray {("https://underware.gg/token/")}
    pub fn CONTRACT_URI()   -> ByteArray {("https://underware.gg/contract.json")}
    pub fn MAX_SUPPLY()     -> u256 {(10)}
    pub fn TREASURY()       -> ContractAddress {(starknet::contract_address_const::<0x1234>())}
    pub fn ROYALTY_FEE()    -> u128 {(500)}
    //*************************************

    fn ZERO() -> ContractAddress {(starknet::contract_address_const::<0x0>())}

    fn dojo_init(
        ref self: ContractState,
    ) {
        self.erc721_combo.initializer(
            TOKEN_NAME(),
            TOKEN_SYMBOL(),
            BASE_URI(),
            CONTRACT_URI(),
            MAX_SUPPLY(),
        );
        // set default royalty to 5%
        self.erc721_combo._set_default_royalty(TREASURY(), ROYALTY_FEE());
        // usually it's a good idea to deploy paused and unpause later
        self.erc721_combo._set_minting_paused(true);
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"example"))
        }
        #[inline(always)]
        fn assert_caller_is_owner(self: @ContractState) {
            let world: WorldStorage = self.world_default();
            assert(world.dispatcher.is_owner(
                selector_from_tag!("example-character"),
                starknet::get_caller_address()
            ), Errors::CALLER_IS_NOT_OWNER);
        }
    }

    //-----------------------------------
    // Public
    //
    #[abi(embed_v0)]
    impl CharacterPublicImpl of super::ICharacterPublic<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress) {
            let _token_id = self.erc721_combo._mint_next(recipient);
        }
        fn burn(ref self: ContractState, token_id: u128) {
            // only owner is supposed to burn
            self.erc721_combo._require_owner_of(starknet::get_caller_address(), token_id.into());
            self.erc721.burn(token_id.into());
        }
        fn pause(ref self: ContractState, paused: bool) {
            // assert caller is owner (contract deployer)
            self.assert_caller_is_owner();
            self.erc721_combo._set_minting_paused(paused);
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
            (match tester.enable_uri_hooks {
                true => { Option::Some(format!("{{\"name\":\"{} #{}\"}}", self.name(), token_id)) },
                false => { Option::None },
            })
        }
        fn render_contract_uri(self: @ContractState) -> Option<ByteArray> {
            let mut store: Store = StoreTrait::new(self.world_default());
            let tester: Tester = store.get_tester();
            (match tester.enable_uri_hooks {
                true => { Option::Some(format!("{{\"name\":\"{} ERC-721 token\"}}", self.name())) },
                false => { Option::None },
            })
        }
    }


    //-----------------------------------
    // ERC721HooksTrait
    //
    pub impl ERC721ComboHooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
        fn token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<ByteArray> {
            (self.get_contract().render_token_uri(token_id))
        }
        fn contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState> ) -> Option<ByteArray> {
            (self.get_contract().render_contract_uri())
        }

        // optional hooks from ERC721Component::ERC721HooksTrait
        // fn before_update(ref self: ERC721ComboComponent::ComponentState<ContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
        // fn after_update(ref self: ERC721ComboComponent::ComponentState<ContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
    }

}
