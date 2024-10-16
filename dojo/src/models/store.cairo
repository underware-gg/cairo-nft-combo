use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use oz_token::models::{
    token_config::{
        TokenConfig, TokenConfigStore,
        TokenConfigEntity, TokenConfigEntityStore,
    },
};

#[derive(Copy, Drop)]
pub struct Store {
    world: IWorldDispatcher,
}

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        (Store { world: world })
    }

    //
    // Getters
    //

    // #[inline(always)]
    // fn get_challenge(self: Store, duel_id: u128) -> Challenge {
    //     // (get!(self.world, duel_id, (Challenge)))
    //     // dojo::model::ModelEntity::<ChallengeEntity>::get(self.world, 1); // OK
    //     // let mut challenge_entity = ChallengeEntityStore::get(self.world, 1); // OK
    //     // challenge_entity.update(self.world); // ERROR
    //     (ChallengeStore::get(self.world, duel_id))
    // }

    #[inline(always)]
    fn get_token_config(self: Store, contract_address: ContractAddress) -> TokenConfig {
        (TokenConfigStore::get(self.world, contract_address))
    }

    #[inline(always)]
    fn get_token_config_entity(self: Store, contract_address: ContractAddress) -> TokenConfigEntity {
        (TokenConfigEntityStore::get(self.world,
            TokenConfigStore::entity_id_from_keys(contract_address)
        ))
    }

    //
    // Setters
    //

    #[inline(always)]
    fn set_token_config(self: Store, model: @TokenConfig) {
        model.set(self.world);
    }

    #[inline(always)]
    fn set_token_config_entity(self: Store, entity: @TokenConfigEntity) {
        entity.update(self.world);
    }

}
