use starknet::{ContractAddress};
use dojo::world::{WorldStorage, WorldStorageTrait, IWorldDispatcher};

pub use example::systems::{
    actions::{IActionsDispatcher, IActionsDispatcherTrait},
    cash::{ICashDispatcher, ICashDispatcherTrait},
    character::{ICharacterDispatcher, ICharacterDispatcherTrait},
};
pub use example::libs::store::{Store, StoreTrait};

#[generate_trait]
pub impl DnsImpl of DnsTrait {
    fn contract_address(self: @WorldStorage, contract_name: @ByteArray) -> ContractAddress {
        // let (contract_address, _) = self.dns(contract_name).unwrap(); // will panic if not found
        match self.dns(contract_name) {
            Option::Some((contract_address, _)) => {
                (contract_address)
            },
            Option::None => {
                assert!(false, "DnsTrait:: contract not found [{}]", contract_name);
                (starknet::contract_address_const::<0x0>())
            },
        }
    }

    // Create a Store from a dispatcher
    // https://github.com/dojoengine/dojo/blob/main/crates/dojo/core/src/contract/components/world_provider.cairo
    // https://github.com/dojoengine/dojo/blob/main/crates/dojo/core/src/world/storage.cairo
    #[inline(always)]
    fn storage(dispatcher: IWorldDispatcher, namespace: @ByteArray) -> WorldStorage {
        (WorldStorageTrait::new(dispatcher, namespace))
    }

    
    //--------------------------
    // system addresses
    //
    #[inline(always)]
    fn actions_address(self: @WorldStorage) -> ContractAddress {
        (self.contract_address(@"actions"))
    }
    #[inline(always)]
    fn cash_address(self: @WorldStorage) -> ContractAddress {
        (self.contract_address(@"cash"))
    }
    #[inline(always)]
    fn character_address(self: @WorldStorage) -> ContractAddress {
        (self.contract_address(@"character"))
    }


    //--------------------------
    // dispatchers
    //
    #[inline(always)]
    fn actions_dispatcher(self: @WorldStorage) -> IActionsDispatcher {
        (IActionsDispatcher{ contract_address: self.actions_address() })
    }
    #[inline(always)]
    fn cash_dispatcher(self: @WorldStorage) -> ICashDispatcher {
        (ICashDispatcher{ contract_address: self.cash_address() })
    }
    #[inline(always)]
    fn character_dispatcher(self: @WorldStorage) -> ICharacterDispatcher {
        (ICharacterDispatcher{ contract_address: self.character_address() })
    }
}
