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
        MetadataUpdate: MetadataUpdate,
        BatchMetadataUpdate: BatchMetadataUpdate,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ContractURIUpdated {}

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct MetadataUpdate {
        #[key]
        pub token_id: u256,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct BatchMetadataUpdate {
        #[key]
        pub from_token_id: u256,
        #[key]
        pub to_token_id: u256,
    }

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
        fn token_uri(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> Option<ByteArray> { (Option::None) }

        //
        // ERC-7572
        // Contract-level metadata
        //
        fn contract_uri(
            self: @ComponentState<TContractState>,
        ) -> Option<ByteArray> { (Option::None)  }
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
            src5_component.register_interface(interface::IERC4906_ID);
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
            (match Hooks::token_uri(self, token_id) {
                Option::Some(custom_uri) => { (custom_uri) },
                Option::None => { (erc721.token_uri(token_id)) },
            })
        }

        // IERC721CamelOnly
        #[inline(always)]
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            (Self::balance_of(self, account))
        }
        #[inline(always)]
        fn ownerOf(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            (Self::owner_of(self, tokenId))
        }
        #[inline(always)]
        fn safeTransferFrom(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>) {
            Self::safe_transfer_from(ref self, from, to, tokenId, data);
        }
        #[inline(always)]
        fn transferFrom(ref self: ComponentState<TContractState>, from: ContractAddress, to: ContractAddress, tokenId: u256) {
            Self::transfer_from(ref self, from, to, tokenId);
        }
        #[inline(always)]
        fn setApprovalForAll(ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool,) {
            Self::set_approval_for_all(ref self, operator, approved);
        }
        #[inline(always)]
        fn getApproved(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            (Self::get_approved(self, tokenId))
        }
        #[inline(always)]
        fn isApprovedForAll( self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress) -> bool {
            (Self::is_approved_for_all(self, owner, operator))
        }

        // IERC721MetadataCamelOnly
        #[inline(always)]
        fn tokenURI(self: @ComponentState<TContractState>, tokenId: u256) -> ByteArray {
            (Self::token_uri(self, tokenId))
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

        // IERC4906MetadataUpdate
        #[inline(always)]
        fn metadata_update(ref self: ComponentState<TContractState>, token_id: u256) {
            ERC4906MetadataUpdate::metadata_update(ref self, token_id);
        }
        #[inline(always)]
        fn batch_metadata_update(ref self: ComponentState<TContractState>, from_token_id: u256, to_token_id: u256) {
            ERC4906MetadataUpdate::batch_metadata_update(ref self, from_token_id, to_token_id);
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
            (match Hooks::contract_uri(self) {
                Option::Some(custom_uri) => { (custom_uri) },
                Option::None => { ("") },
            })
        }
        #[inline(always)]
        fn contractURI(self: @ComponentState<TContractState>) -> ByteArray {
            (Self::contract_uri(self))
        }
        fn contract_uri_updated(ref self: ComponentState<TContractState>) {
            self.emit(ContractURIUpdated {});
        }
    }

    #[embeddable_as(ERC4906MetadataUpdateImpl)]
    impl ERC4906MetadataUpdate<
        TContractState,
        +HasComponent<TContractState>,
        +ERC721Component::ERC721HooksTrait<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Hooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of interface::IERC4906MetadataUpdate<ComponentState<TContractState>> {
        fn metadata_update(ref self: ComponentState<TContractState>, token_id: u256) {
            self.emit(MetadataUpdate {
                token_id,
            });
        }
        fn batch_metadata_update(ref self: ComponentState<TContractState>, from_token_id: u256, to_token_id: u256) {
            self.emit(BatchMetadataUpdate {
                from_token_id,
                to_token_id,
            });
        }
    }

}
