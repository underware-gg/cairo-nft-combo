use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct TokenConfig {
    #[key]
    pub token_address: ContractAddress,
    //------
    pub minter_contract: ContractAddress,
    pub minted_count: u128,
}
