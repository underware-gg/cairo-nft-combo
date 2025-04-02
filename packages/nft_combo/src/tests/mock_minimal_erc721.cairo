use starknet::{ContractAddress};

#[starknet::interface]
pub trait IMinimalERC721Mock<TState> {
    fn mint(ref self: TState, recipient: ContractAddress);
    fn burn(ref self: TState, token_id: u256);
}

#[starknet::contract]
pub mod MinimalERC721Mock {
    use starknet::ContractAddress;

    //-----------------------------------
    // ERC721 start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    use crate::erc721::erc721_combo::{ERC721ComboComponent, ERC721ComboHooksEmptyImpl};
    use crate::erc721::erc721_combo::ERC721ComboComponent::{ERC721HooksImpl};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;
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
    // ERC721 end
    //-----------------------------------

    fn TOKEN_NAME()     -> ByteArray {("Minimal")}
    fn TOKEN_SYMBOL()   -> ByteArray {("MINI")}
    fn BASE_URI()       -> ByteArray {("")}

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.erc721_combo.initializer(
            TOKEN_NAME(),
            TOKEN_SYMBOL(),
            BASE_URI(),
            Option::None,
            Option::None,
        );
    }

    #[abi(embed_v0)]
    impl MinimalERC721MockImpl of super::IMinimalERC721Mock<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress) {
            let _token_id = self.erc721_combo._mint_next(recipient);
        }
        fn burn(ref self: ContractState, token_id: u256) {
            // only owner is supposed to burn
            self.erc721_combo._require_owner_of(starknet::get_caller_address(), token_id);
            self.erc721.burn(token_id.into());
        }
    }

}
