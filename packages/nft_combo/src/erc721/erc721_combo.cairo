#[starknet::component]
pub mod ERC721ComboComponent {
    use starknet::{ContractAddress};
    // use openzeppelin_token::erc721::interface;
    use openzeppelin_token::erc721::{ERC721Component};
    use openzeppelin_token::erc721::ERC721Component::{
        InternalImpl as ERC721InternalImpl,
        ERC721Impl,
        ERC721MetadataImpl,
    };
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_introspection::src5::SRC5Component::SRC5Impl;
    use openzeppelin_introspection::src5::SRC5Component::InternalTrait as SRC5InternalTrait;
    use crate::erc721::interface;

    #[storage]
    pub struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        ContractURIUpdated: ContractURIUpdated,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ContractURIUpdated {}

    //-----------------------------------------
    // Combo Hooks
    //
    // (your contract MUST implement this trait)
    //
    pub trait ERC721ComboHooksTrait<TContractState> {
        //
        // ERC-721 Metadata
        // Custom renderer for `token_uri()`
        // for fully on-chain metadata
        //
        fn render_token_uri(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> ByteArray {""} // empty string fallback to ERC721Metadata

        //
        // ERC-7572
        // Contract-level metadata
        //
        fn render_contract_uri(
            self: @ComponentState<TContractState>,
        ) -> ByteArray {""}
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Hooks: ERC721Component::ERC721HooksTrait<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Initializes the contract by setting the token name, symbol, and base URI.
        /// This should only be used inside the contract's constructor.
        fn initializer(
            ref self: ComponentState<TContractState>,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
        ) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.initializer(name, symbol, base_uri);
            let mut src5_component = get_dep_component_mut!(ref self, SRC5);
            src5_component.register_interface(interface::IERC7572_ID);
        }
    }

    //-----------------------------------------
    // ERC721ABI mixin
    // cloned from ERC721Component::ERC721Mixin
    // https://github.com/OpenZeppelin/cairo-contracts/blob/v0.20.0/packages/token/src/erc721/erc721.cairo#L342
    //
    #[embeddable_as(ERC721ComboMixinImpl)]
    pub impl ERC721ComboMixin<
        TContractState,
        +HasComponent<TContractState>,
        +ERC721Component::ERC721HooksTrait<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Hooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    // > of interface::ERC721ABI<ComponentState<TContractState>> {
    > of interface::IERC721ComboABI<ComponentState<TContractState>> {
        // ISRC5
        fn supports_interface(self: @ComponentState<TContractState>, interface_id: felt252) -> bool {
            let src5 = get_dep_component!(self, SRC5);
            (src5.supports_interface(interface_id))
        }

        // IERC721
        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            let erc721 = get_dep_component!(self, ERC721);
            (erc721.balance_of(account))
        }
        fn owner_of(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            let erc721 = get_dep_component!(self, ERC721);
            (erc721.owner_of(token_id))
        }
        fn safe_transfer_from(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.safe_transfer_from(from, to, token_id, data);
        }
        fn transfer_from(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, token_id: u256) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.transfer_from(from, to, token_id);
        }
        fn approve(ref self: ComponentState<TContractState>, to: ContractAddress, token_id: u256) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.approve(to, token_id);
        }
        fn set_approval_for_all(ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.set_approval_for_all(operator, approved);
        }
        fn get_approved(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            let erc721 = get_dep_component!(self, ERC721);
            (erc721.get_approved(token_id))
        }
        fn is_approved_for_all(self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress) -> bool {
            let erc721 = get_dep_component!(self, ERC721);
            (erc721.is_approved_for_all(owner, operator))
        }

        // IERC721Metadata
        fn name(self: @ComponentState<TContractState>) -> ByteArray {
            let erc721 = get_dep_component!(ref self, ERC721);
            (erc721.name())
        }
        fn symbol(self: @ComponentState<TContractState>) -> ByteArray {
            let erc721 = get_dep_component!(ref self, ERC721);
            (erc721.symbol())
        }
        fn token_uri(self: @ComponentState<TContractState>, token_id: u256) -> ByteArray {
            let erc721 = get_dep_component!(ref self, ERC721);
            erc721._require_owned(token_id);
            let custom_uri = Hooks::render_token_uri(self, token_id);
            if (custom_uri.len() > 0) {
                (custom_uri)
            } else {
                erc721.token_uri(token_id)
            }
        }

        // IERC721CamelOnly
        #[inline(always)]
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            (self.balance_of(account))
        }
        #[inline(always)]
        fn ownerOf(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            (self.owner_of(tokenId))
        }
        #[inline(always)]
        fn safeTransferFrom(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>) {
            self.safe_transfer_from(from, to, tokenId, data);
        }
        #[inline(always)]
        fn transferFrom(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, tokenId: u256) {
            self.transfer_from(from, to, tokenId);
        }
        #[inline(always)]
        fn setApprovalForAll(ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool,) {
            self.set_approval_for_all(operator, approved);
        }
        #[inline(always)]
        fn getApproved(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            (self.get_approved(tokenId))
        }
        #[inline(always)]
        fn isApprovedForAll( self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress) -> bool {
            (self.is_approved_for_all(owner, operator))
        }

        // IERC721MetadataCamelOnly
        #[inline(always)]
        fn tokenURI(self: @ComponentState<TContractState>, tokenId: u256) -> ByteArray {
            (self.token_uri(tokenId))
        }

        // IERC7572ContractMetadata
        #[inline(always)]
        fn contract_uri(self: @ComponentState<TContractState>) -> ByteArray {
            (ERC7572ContractMetadata::contract_uri(self))
        }
        #[inline(always)]
        fn contractURI(self: @ComponentState<TContractState>) -> ByteArray {
            (ERC7572ContractMetadata::contract_uri(self))
        }
        #[inline(always)]
        fn contract_uri_updated(ref self: ComponentState<TContractState>) {
            ERC7572ContractMetadata::contract_uri_updated(ref self);
        }
    }

    #[embeddable_as(ERC7572ContractMetadataImpl)]
    impl ERC7572ContractMetadata<
        TContractState,
        +HasComponent<TContractState>,
        +ERC721Component::ERC721HooksTrait<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Hooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of interface::IERC7572ContractMetadata<ComponentState<TContractState>> {
        fn contract_uri(self: @ComponentState<TContractState>) -> ByteArray {
            (Hooks::render_contract_uri(self))
        }
        #[inline(always)]
        fn contractURI(self: @ComponentState<TContractState>) -> ByteArray {
            (Self::contract_uri(self))
        }

        // emit `ContractURIUpdated`
        fn contract_uri_updated(ref self: ComponentState<TContractState>) {
println!("--- ContractURIUpdated!");
            self.emit(ContractURIUpdated {});
        }
    }

}
