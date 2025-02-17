use starknet::{ContractAddress};
use dojo::world::{WorldStorage};
use dojo::model::{ModelStorage, ModelValueStorage};

// re-export models
pub use example::models::{
    token_config::{TokenConfig, TokenConfigValue},
    coin_config::{CoinConfig, CoinConfigValue},
    tester::{Tester},
};

#[derive(Copy, Drop)]
pub struct Store {
    pub world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: WorldStorage) -> Store {
        (Store { world })
    }

    //
    // Getters
    //

    #[inline(always)]
    fn get_token_config(ref self: Store, contract_address: ContractAddress) -> TokenConfig {
        (self.world.read_model(contract_address))
    }
    #[inline(always)]
    fn get_token_config_value(ref self: Store, contract_address: ContractAddress) -> TokenConfigValue {
        (self.world.read_value(contract_address))
    }

    #[inline(always)]
    fn get_coin_config(ref self: Store, contract_address: ContractAddress) -> CoinConfig {
        (self.world.read_model(contract_address))
    }
    #[inline(always)]
    fn get_coin_config_value(ref self: Store, contract_address: ContractAddress) -> CoinConfigValue {
        (self.world.read_value(contract_address))
    }

    #[inline(always)]
    fn get_tester(ref self: Store) -> Tester {
        (self.world.read_model(1))
    }

    //
    // Setters
    //

    #[inline(always)]
    fn set_token_config(ref self: Store, model: @TokenConfig) {
        self.world.write_model(model);
    }

    #[inline(always)]
    fn set_coin_config(ref self: Store, model: @CoinConfig) {
        self.world.write_model(model);
    }

    #[inline(always)]
    fn set_tester(ref self: Store, model: @Tester) {
        self.world.write_model(model);
    }
}
