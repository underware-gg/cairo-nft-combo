#[starknet::component]
pub mod ERC721ComboComponent {
    use core::num::traits::Zero;
    use starknet::{ContractAddress};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use openzeppelin_token::erc721::{ERC721Component};
    use openzeppelin_token::erc721::ERC721Component::{
        InternalImpl as ERC721InternalImpl,
        ERC721Impl,
        ERC721MetadataImpl,
    };
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_introspection::src5::SRC5Component::SRC5Impl;
    use openzeppelin_introspection::src5::SRC5Component::InternalTrait as SRC5InternalTrait;
    use crate::common::{interface as common_interface};
    use crate::common::{renderer};
    use crate::erc721::interface;

    #[storage]
    pub struct Storage {
        pub ERC721_max_supply: u256,
        pub ERC721_total_supply: u256,
        pub ERC721_last_token_id: u256,
        pub ERC721_minting_paused: bool,
        pub ERC7572_contract_uri: ByteArray,
        pub ERC2981_default_royalty_info: RoyaltyInfo,
    }

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

    #[derive(Serde, Drop, starknet::Store)]
    pub struct RoyaltyInfo {
        pub receiver: ContractAddress,
        pub royalty_fraction: u128,
    }

    pub const ROYALTY_FEE_DENOMINATOR: u128 = 10_000;

    pub mod Errors {
        pub const REACHED_MAX_SUPPLY: felt252 = 'ERC721Combo: reached max supply';
        pub const MINTING_IS_PAUSED: felt252 = 'ERC721Combo: minting is paused';
        pub const NOT_OWNER: felt252 = 'ERC721Combo: not owner';
        pub const INVALID_ROYALTY: felt252 = 'ERC721Combo: invalid royalty';
        pub const INVALID_ROYALTY_RECEIVER: felt252 = 'ERC721Combo: invalid receiver';
    }

    //-----------------------------------------
    // Combo Hooks
    //
    // your contract must implement this trait, or import ERC721ComboHooksEmptyImpl
    // see character.cairo for example
    //
    pub trait ERC721ComboHooksTrait<TContractState> {
        //
        // ERC-721 Metadata
        // Custom token metadata, either...
        // 1. pass the metadata to be rendered by the component
        fn render_token_uri(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> Option<renderer::TokenMetadata> {(Option::None)}
        // 2. or pass the rendered uri, which can be a url or a json string prefixed with `data:application/json,`
        fn token_uri(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> Option<ByteArray> {(Option::None)}

        //
        // ERC-7572
        // Contract-level metadata, either...
        // 1. pass the metadata to be rendered by the component
        fn render_contract_uri(
            self: @ComponentState<TContractState>,
        ) -> Option<renderer::ContractMetadata> {(Option::None)}
        // 2. or pass the rendered uri, which can be a url or a json string prefixed with `data:application/json,`
        fn contract_uri(
            self: @ComponentState<TContractState>,
        ) -> Option<ByteArray> {(Option::None)}

        //
        // ERC-2981
        // Default royalty info
        fn default_royalty(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> Option<RoyaltyInfo> {(Option::None)}
        // Per-token royalty info
        fn token_royalty(
            self: @ComponentState<TContractState>,
            token_id: u256,
        ) -> Option<RoyaltyInfo> {(Option::None)}

        //
        // ERC721Component::ERC721HooksTrait
        fn before_update(
            ref self: ComponentState<TContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) {}
        fn after_update(
            ref self: ComponentState<TContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) {}
    }

    //
    // ERC721Component::ERC721HooksTrait
    // (must be imported by contracts)
    //
    pub impl ERC721HooksImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl ComboHooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of ERC721Component::ERC721HooksTrait<TContractState> {
        fn before_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {
            let mut contract = self.get_contract_mut();
            let mut comp = HasComponent::get_component_mut(ref contract);
            let mut erc721 = ERC721Component::HasComponent::get_component_mut(ref contract);
            if (erc721._owner_of(token_id).is_zero()) {
                // minting...
                assert(token_id <= ERC721Minter::max_supply(@comp), Errors::REACHED_MAX_SUPPLY);
                assert(!ERC721Minter::is_minting_paused(@comp), Errors::MINTING_IS_PAUSED);
                let supply = ERC721Minter::total_supply(@comp);
                comp.ERC721_total_supply.write(supply + 1);
                comp.ERC721_last_token_id.write(token_id);
            } else if (to.is_zero()) {
                // burning...
                let supply = ERC721Minter::total_supply(@comp);
                comp.ERC721_total_supply.write(supply - 1);
            }
            // call user hook if implemented
            ComboHooks::before_update(ref comp, to, token_id, auth);
        }
        fn after_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {
            let mut contract = self.get_contract_mut();
            let mut comp = HasComponent::get_component_mut(ref contract);
            // call user hook if implemented
            ComboHooks::after_update(ref comp, to, token_id, auth);
        }
    }


    //-----------------------------------------
    // Internal
    //
    // functions can be called by the contract but not by users
    //
    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl ComboHooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Initializes the contract by setting the token name, symbol, and base URI.
        /// This should only be used inside the contract's constructor.
        fn initializer(
            ref self: ComponentState<TContractState>,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
            contract_uri: ByteArray,
            max_supply: u256,
        ) {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            erc721.initializer(name, symbol, base_uri);
            self._set_contract_uri(contract_uri);
            self._set_max_supply(max_supply);
            let mut src5_component = get_dep_component_mut!(ref self, SRC5);
            src5_component.register_interface(interface::IERC721Minter_ID);
            src5_component.register_interface(common_interface::IERC7572_ID);
            src5_component.register_interface(common_interface::IERC4906_ID);
            src5_component.register_interface(common_interface::IERC2981_ID);
        }

        /// IERC721Minter
        fn _mint_next(ref self: ComponentState<TContractState>, recipient: ContractAddress) -> u256 {
            let mut erc721 = get_dep_component_mut!(ref self, ERC721);
            let token_id = ERC721Minter::last_token_id(@self) + 1;
            erc721.mint(recipient, token_id);
            (token_id)
        }
        fn _set_max_supply(ref self: ComponentState<TContractState>, max_supply: u256) {
            self.ERC721_max_supply.write(max_supply);
        }
        fn _set_minting_paused(ref self: ComponentState<TContractState>, paused: bool) {
            self.ERC721_minting_paused.write(paused);
        }
        fn _require_owner_of(self: @ComponentState<TContractState>, caller: ContractAddress, token_id: u256) -> ContractAddress {
            let mut erc721 = get_dep_component!(self, ERC721);
            let owner = erc721._owner_of(token_id);
            assert(!owner.is_zero() && owner == caller, Errors::NOT_OWNER);
            (owner)
        }

        /// IERC7572ContractMetadata
        fn _set_contract_uri(ref self: ComponentState<TContractState>, contract_uri: ByteArray) {
            self.ERC7572_contract_uri.write(contract_uri);
            self._emit_contract_uri_updated();
        }
        fn _contract_uri(self: @ComponentState<TContractState>) -> ByteArray {
            (self.ERC7572_contract_uri.read())
        }
        fn _emit_contract_uri_updated(ref self: ComponentState<TContractState>) {
            self.emit(ContractURIUpdated {});
        }

        // IERC4906MetadataUpdate
        fn _emit_metadata_update(ref self: ComponentState<TContractState>, token_id: u256) {
            self.emit(MetadataUpdate {
                token_id,
            });
        }
        fn _emit_batch_metadata_update(ref self: ComponentState<TContractState>, from_token_id: u256, to_token_id: u256) {
            self.emit(BatchMetadataUpdate {
                from_token_id,
                to_token_id,
            });
        }

        /// IERC2981RoyaltyInfo
        fn _set_default_royalty(ref self: ComponentState<TContractState>, receiver: ContractAddress, fee_numerator: u128) {
            assert(fee_numerator <= ROYALTY_FEE_DENOMINATOR, Errors::INVALID_ROYALTY);
            assert(receiver.is_non_zero(), Errors::INVALID_ROYALTY_RECEIVER);
            self.ERC2981_default_royalty_info.write(RoyaltyInfo { receiver, royalty_fraction: fee_numerator })
        }
        fn _delete_default_royalty(ref self: ComponentState<TContractState>) {
            self.ERC2981_default_royalty_info.write(RoyaltyInfo { receiver: Zero::zero(), royalty_fraction: 0 })
        }
        fn _get_royalty_info(self: @ComponentState<TContractState>, token_id: u256) -> RoyaltyInfo {
            (match ComboHooks::token_royalty(self, token_id) {
                Option::Some(token_royalty_info) => { (token_royalty_info) }, // 1: Per-token royalty hook
                Option::None => { 
                    (match ComboHooks::default_royalty(self, token_id) {
                        Option::Some(default_royalty_info) => { (default_royalty_info) }, // 2: Default royalty hook
                        Option::None => { (self.ERC2981_default_royalty_info.read()) }, // 3: Default royalty set, or none
                    })
                 },
            })
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
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl ComboHooks: ERC721ComboHooksTrait<TContractState>,
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
            (match ComboHooks::render_token_uri(self, token_id) {
                Option::Some(metadata) => {
                    (renderer::MetadataRenderer::render_token_metadata(metadata))
                },
                Option::None => {
                    (match ComboHooks::token_uri(self, token_id) {
                        Option::Some(custom_uri) => { (custom_uri) },
                        Option::None => { (erc721.token_uri(token_id)) },
                    })
                },
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

        // IERC721Minter
        #[inline(always)]
        fn max_supply(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::max_supply(self))
        }
        #[inline(always)]
        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::total_supply(self))
        }
        #[inline(always)]
        fn last_token_id(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::last_token_id(self))
        }
        #[inline(always)]
        fn is_minting_paused(self: @ComponentState<TContractState>) -> bool {
            (ERC721Minter::is_minting_paused(self))
        }

        // IERC721MinterCamelOnly
        #[inline(always)]
        fn maxSupply(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::max_supply(self))
        }
        #[inline(always)]
        fn totalSupply(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::total_supply(self))
        }
        #[inline(always)]
        fn lastTokenId(self: @ComponentState<TContractState>) -> u256 {
            (ERC721Minter::last_token_id(self))
        }
        #[inline(always)]
        fn isMintingPaused(self: @ComponentState<TContractState>) -> bool {
            (ERC721Minter::is_minting_paused(self))
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

        // IERC4906MetadataUpdate

        // IERC2981RoyaltyInfo
        #[inline(always)]
        fn royalty_info(self: @ComponentState<TContractState>, token_id: u256, sale_price: u256) -> (ContractAddress, u256) {
            (ERC2981RoyaltyInfo::royalty_info(self, token_id, sale_price))
        }
        fn royaltyInfo(self: @ComponentState<TContractState>, token_id: u256, sale_price: u256) -> (ContractAddress, u256) {
            (ERC2981RoyaltyInfo::royalty_info(self, token_id, sale_price))
        }
        #[inline(always)]
        fn token_royalty(self: @ComponentState<TContractState>, token_id: u256) -> (ContractAddress, u128, u128) {
            (ERC2981RoyaltyInfo::token_royalty(self, token_id))
        }
        #[inline(always)]
        fn tokenRoyalty(self: @ComponentState<TContractState>, token_id: u256) -> (ContractAddress, u128, u128) {
            (ERC2981RoyaltyInfo::token_royalty(self, token_id))
        }
        #[inline(always)]
        fn default_royalty(self: @ComponentState<TContractState>) -> (ContractAddress, u128, u128) {
            (ERC2981RoyaltyInfo::default_royalty(self))
        }
        #[inline(always)]
        fn defaultRoyalty(self: @ComponentState<TContractState>) -> (ContractAddress, u128, u128) {
            (ERC2981RoyaltyInfo::default_royalty(self))
        }
    }


    #[embeddable_as(ERC721MinterImpl)]
    impl ERC721Minter<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
    > of interface::IERC721Minter<ComponentState<TContractState>> {
        fn max_supply(self: @ComponentState<TContractState>) -> u256 {
            self.ERC721_max_supply.read()
        }
        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            self.ERC721_total_supply.read()
        }
        fn last_token_id(self: @ComponentState<TContractState>) -> u256 {
            self.ERC721_last_token_id.read()
        }
        fn is_minting_paused(self: @ComponentState<TContractState>) -> bool {
            self.ERC721_minting_paused.read()
        }
    }

    #[embeddable_as(ERC7572ContractMetadataImpl)]
    impl ERC7572ContractMetadata<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl ComboHooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of common_interface::IERC7572ContractMetadata<ComponentState<TContractState>> {
        fn contract_uri(self: @ComponentState<TContractState>) -> ByteArray {
            (match ComboHooks::render_contract_uri(self) {
                Option::Some(metadata) => {
                    (renderer::MetadataRenderer::render_contract_metadata(metadata))
                },
                Option::None => {
                    (match ComboHooks::contract_uri(self) {
                        Option::Some(custom_uri) => { (custom_uri) },
                        Option::None => { (self._contract_uri()) },
                    })
                },
            })
        }
    }

    #[embeddable_as(ERC4906MetadataUpdateImpl)]
    impl ERC4906MetadataUpdate<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
    > of common_interface::IERC4906MetadataUpdate<ComponentState<TContractState>> {
    }

    #[embeddable_as(ERC2981RoyaltyInfoImpl)]
    impl ERC2981RoyaltyInfo<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl ComboHooks: ERC721ComboHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of common_interface::IERC2981RoyaltyInfo<ComponentState<TContractState>> {
        fn royalty_info(self: @ComponentState<TContractState>, token_id: u256, sale_price: u256) -> (ContractAddress, u256) {
            let royalty_info: RoyaltyInfo = self._get_royalty_info(token_id);
            let royalty_amount: u256 = sale_price
                * royalty_info.royalty_fraction.into()
                / ROYALTY_FEE_DENOMINATOR.into();
            (royalty_info.receiver, royalty_amount)
        }
        fn default_royalty(self: @ComponentState<TContractState>) -> (ContractAddress, u128, u128) {
            let royalty_info = self.ERC2981_default_royalty_info.read();
            (royalty_info.receiver, royalty_info.royalty_fraction, ROYALTY_FEE_DENOMINATOR)
        }
        fn token_royalty(self: @ComponentState<TContractState>, token_id: u256) -> (ContractAddress, u128, u128) {
            let royalty_info: RoyaltyInfo = self._get_royalty_info(token_id);
            (royalty_info.receiver, royalty_info.royalty_fraction, ROYALTY_FEE_DENOMINATOR)
        }
    }
}


/// An empty implementation of the ERC721ComboHooksTrait
pub impl ERC721ComboHooksEmptyImpl<
    TContractState,
> of ERC721ComboComponent::ERC721ComboHooksTrait<TContractState> {}
