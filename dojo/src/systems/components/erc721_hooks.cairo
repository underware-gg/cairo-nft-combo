use starknet::{ContractAddress, get_contract_address};
use openzeppelin_token::erc721::{ERC721Component};    
use oz_token::systems::character::{ICharacter, ICharacterDispatcher, ICharacterDispatcherTrait};

pub impl ERC721HooksImpl<TContractState> of ERC721Component::ERC721HooksTrait<TContractState> {
    fn before_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
    fn after_update(ref self: ERC721Component::ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
    fn token_uri(
        self: @ERC721Component::ComponentState<TContractState>,
        token_id: u256,
    ) -> ByteArray {
        ICharacterDispatcher{
            contract_address: get_contract_address()
        }.render_uri(token_id)
    }
}
