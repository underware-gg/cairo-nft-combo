use core::num::traits::Zero;
use starknet::{ContractAddress};
use openzeppelin_introspection::{interface as src5_interface};
use openzeppelin_token::erc721::{interface as erc721_interface};
use nft_combo::erc721::erc721_combo::{ERC721ComboComponent as combo};
use nft_combo::common::{interface as common_interface};
use crate::systems::character::{character};
use crate::tests::tester::{
    tester,
    tester::{
        setup_world, TestSystems,
        // IActionsDispatcherTrait,
        ICharacterDispatcherTrait,
        // ICashDispatcherTrait,
        OWNER, OTHER, RECEIVER,
        WEI,
    }
};

const TOKEN_ID_1: u256 = 1;
const TOKEN_ID_2: u256 = 2;
const TOKEN_ID_3: u256 = 3;
const TOKEN_ID_4: u256 = 4;

fn _mint(mut sys: TestSystems, recipient: ContractAddress   ) {
    // tester::impersonate(sys.actions.contract_address);
    sys.character.mint(recipient);
}

fn _mint_reserved(mut sys: TestSystems, recipient: ContractAddress   ) {
    tester::impersonate(OWNER()); // only owner can mint reserved
    sys.character.mint_reserved(recipient);
}

#[test]
fn test_initializer() {
    let sys: TestSystems = setup_world(true, 0);
    println!("___character SYMBOL:[{}] NAME:[{}]", sys.character.symbol(), sys.character.name());
    assert_ne!(sys.character.symbol(), "", "Name is empty");
    assert_ne!(sys.character.name(), "", "Name is empty");
    assert_eq!(sys.character.symbol(), character::TOKEN_SYMBOL(), "Symbol is wrong");
    assert_eq!(sys.character.name(), character::TOKEN_NAME(), "Name is wrong");
    assert!(sys.character.supports_interface(src5_interface::ISRC5_ID), "should support ISRC5_ID");
    assert!(sys.character.supports_interface(erc721_interface::IERC721_ID), "should support IERC721_ID");
    assert!(sys.character.supports_interface(erc721_interface::IERC721_METADATA_ID), "should support METADATA");
    assert!(sys.character.supports_interface(common_interface::IERC7572_ID), "should support IERC7572_ID");
    assert!(sys.character.supports_interface(common_interface::IERC4906_ID), "should support IERC4906_ID");
    assert!(sys.character.supports_interface(common_interface::IERC2981_ID), "should support IERC2981_ID");
}


//
// mint / burn / supply
//

#[test]
#[should_panic(expected:('ERC721Combo: minting is paused', 'ENTRYPOINT_FAILED'))]
fn test_mint_paused() {
    let sys: TestSystems = setup_world(false, 0);
    _mint(sys, OWNER());
}

#[test]
fn test_mint_unpause() {
    let sys: TestSystems = setup_world(false, 0);
    tester::impersonate(OWNER());
    sys.character.pause(false);
    _mint(sys, OWNER());
    // no panic!
}

#[test]
#[should_panic(expected:('CHARACTER: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_mint_unpause_not_owner() {
    let sys: TestSystems = setup_world(false, 0);
    tester::impersonate(OTHER());
    sys.character.pause(false);
}

#[test]
fn test_mint_burn_supply() {
    let sys: TestSystems = setup_world(true, 0);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) : 0");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) : 0");
    assert_eq!(sys.character.max_supply(), 10, "max_supply: 10");
    assert_eq!(sys.character.available_supply(), 10, "available_supply: 10");
    assert_eq!(sys.character.reserved_supply(), 0, "reserved_supply: 0");
    assert_eq!(sys.character.total_supply(), 0, "total_supply: 0");
    assert_eq!(sys.character.minted_supply(), 0, "minted_supply: 0");
    assert_eq!(sys.character.last_token_id(), 0, "last_token_id : 0");
    assert!(!sys.character.token_exists(TOKEN_ID_1), "!exists(TOKEN_ID_1)");
    // mint TOKEN_ID_1
    _mint(sys, OWNER());
    assert_eq!(sys.character.max_supply(), 10, "max_supply: 10 still");
    assert_eq!(sys.character.available_supply(), 9, "available_supply: 9");
    assert!(sys.character.token_exists(TOKEN_ID_1), "exists(TOKEN_ID_1)");
    assert!(sys.character.is_owner_of(OWNER(), TOKEN_ID_1), "is_owner_of(OWNER(), TOKEN_ID_1)");
    assert!(!sys.character.is_owner_of(OTHER(), TOKEN_ID_1), "!is_owner_of(OTHER(), TOKEN_ID_1)");
    assert_eq!(sys.character.owner_of(TOKEN_ID_1), OWNER(), "owner_of_1");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) +1");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) +0");
    assert_eq!(sys.character.total_supply(), 1, "total_supply +1");
    assert_eq!(sys.character.minted_supply(), 1, "minted_supply +1");
    assert_eq!(sys.character.last_token_id(), 1, "last_token_id +1");
    // validate CamelOnly
    assert_eq!(sys.character.totalSupply(), 1, "totalSupply +1");
    // mint TOKEN_ID_2
    _mint(sys, OTHER());
    assert_eq!(sys.character.available_supply(), 8, "available_supply: 8");
    assert_eq!(sys.character.owner_of(TOKEN_ID_2), OTHER(), "owner_of_2");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) =1");
    assert_eq!(sys.character.balance_of(OTHER()), 1, "balance_of (OTHER) +1");
    assert_eq!(sys.character.total_supply(), 2, "total_supply +2");
    assert_eq!(sys.character.minted_supply(), 2, "minted_supply +2");
    assert_eq!(sys.character.last_token_id(), 2, "last_token_id +2");
    // mint TOKEN_ID_3
    _mint(sys, OTHER());
    assert_eq!(sys.character.available_supply(), 7, "available_supply: 7");
    assert_eq!(sys.character.owner_of(TOKEN_ID_3), OTHER(), "owner_of_3");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) ==1");
    assert_eq!(sys.character.balance_of(OTHER()), 2, "balance_of (OTHER) +2");
    assert_eq!(sys.character.total_supply(), 3, "total_supply +3");
    assert_eq!(sys.character.minted_supply(), 3, "minted_supply +3");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id +3");
    // burn TOKEN_ID_1
    tester::impersonate(OWNER());
    sys.character.burn(TOKEN_ID_1);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) -1=0");
    assert_eq!(sys.character.balance_of(OTHER()), 2, "balance_of (OTHER) +1=2");
    assert_eq!(sys.character.total_supply(), 2, "total_supply -1=2");
    assert_eq!(sys.character.minted_supply(), 3, "minted_supply =3");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id =3");
    // burn TOKEN_ID_2, TOKEN_ID_3
    tester::impersonate(OTHER());
    sys.character.burn(TOKEN_ID_2);
    sys.character.burn(TOKEN_ID_3);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) << 0");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) << 0");
    assert_eq!(sys.character.total_supply(), 0, "total_supply << 0");
    assert_eq!(sys.character.minted_supply(), 3, "minted_supply ==3");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id ==3");
    // mint all available tokens
    assert_eq!(sys.character.available_supply(), 7, "available_supply: 7 still");
    let max_supply: u256 = sys.character.max_supply();
    assert_eq!(max_supply, 10, "max_supply == 10");
    while (sys.character.last_token_id() < max_supply) {
        assert!(!sys.character.is_minted_out(), "!is_minted_out");
        _mint(sys, OWNER());
    };
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    assert!(sys.character.is_minted_out(), "is_minted_out");
}

#[test]
#[should_panic(expected:('ERC721Combo: reached max supply', 'ENTRYPOINT_FAILED'))]
fn test_mint_max_supply_panic() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    assert_eq!(max_supply, 10, "max_supply == 10");
    while (sys.character.last_token_id() < max_supply) {
        _mint(sys, OWNER());
    };
    // one more will panic
    _mint(sys, OWNER());
}

#[test]
fn test_mint_set_max_supply_ok() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    while (sys.character.last_token_id() < max_supply) {
        _mint(sys, OWNER());
    };
    // increase and mint out
    tester::impersonate(OWNER());
    sys.character.update_max_supply(Option::Some(15));
    let new_max_supply: u256 = sys.character.max_supply();
    assert_gt!(new_max_supply, max_supply, "new_max_supply");
    while (sys.character.last_token_id() < new_max_supply) {
        _mint(sys, OWNER());
    };
    // no panic!
}

#[test]
fn test_mint_set_max_supply_none_ok() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    sys.character.update_max_supply(Option::None);
    let new_max_supply: u256 = sys.character.max_supply();
    assert_eq!(new_max_supply, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "new_max_supply");
    while (sys.character.last_token_id() < max_supply * 2) {
        _mint(sys, OWNER());
    };
    // no panic!
}

#[test]
#[should_panic(expected:('ERC721Combo: reached max supply', 'ENTRYPOINT_FAILED'))]
fn test_mint_set_max_supply_panic() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    sys.character.update_max_supply(Option::Some(15));
    let new_max_supply: u256 = sys.character.max_supply();
    assert_gt!(new_max_supply, max_supply, "new_max_supply");
    while (sys.character.last_token_id() < new_max_supply) {
        _mint(sys, OWNER());
    };
    // one more will panic
    _mint(sys, OWNER());
}

#[test]
#[should_panic(expected:('CHARACTER: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_mint_set_max_supply_not_owner() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OTHER());
    sys.character.update_max_supply(Option::Some(1000));
}

#[test]
#[should_panic(expected:('ERC721Combo: invalid supply', 'ENTRYPOINT_FAILED'))]
fn test_mint_set_max_supply_invalid() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    while (sys.character.last_token_id() < max_supply) {
        _mint(sys, OWNER());
    };
    // cant set new max supply to less than minted
    tester::impersonate(OWNER());
    sys.character.update_max_supply(Option::Some(max_supply-1));
}

#[test]
#[should_panic(expected:('ERC721Combo: reached max supply', 'ENTRYPOINT_FAILED'))]
fn test_mint_no_max_supply() {
    let sys: TestSystems = setup_world(true, 0);
    // mint all available tokens
    let max_supply: u256 = sys.character.max_supply();
    assert_eq!(max_supply, 10, "max_supply == 10");
    while (sys.character.last_token_id() < max_supply) {
        _mint(sys, OWNER());
    };
    // one more will panic
    _mint(sys, OWNER());
}

#[test]
#[should_panic(expected:('ERC721Combo: not owner', 'ENTRYPOINT_FAILED'))]
fn test_burn_not_owner() {
    let sys: TestSystems = setup_world(true, 0);
    _mint(sys, OWNER());
    tester::impersonate(OTHER());
    sys.character.burn(TOKEN_ID_1);
}

#[test]
// #[should_panic(expected:('ERC721Combo: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_burn_mint_again() {
    let sys: TestSystems = setup_world(true, 0);
    _mint(sys, OWNER());
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) : 0");
    tester::impersonate(OWNER());
    sys.character.burn(TOKEN_ID_1);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) : 1");
    // try to mint the same ID again
    // (it works, but it's not a good idea!)
    sys.character.mint_token_id(OWNER(), TOKEN_ID_1);
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) : 1 again???");
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_not_minted() {
    let sys: TestSystems = setup_world(true, 0);
    sys.character.owner_of(TOKEN_ID_1);
}

//
// token_uri
//

#[test]
fn test_token_uri_default() {
    let mut sys: TestSystems = setup_world(true, 0);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    println!("___token_uri_default(1):[{}]", uri);
    assert_ne!(uri, "", "token_uri() should not be empty");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
    assert!(tester::starts_with(uri, "https:"), "token_uri() should start with https:");
}

#[test]
fn test_token_uri_render_hook() {
    let mut sys: TestSystems = setup_world(true, 0);
    tester::set_enable_uri_render_hooks(ref sys, true);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    println!("___token_uri_render(1):[{}]", uri);
    assert_gt!(uri.len(), 100, "token_uri() len");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
    assert!(tester::starts_with(uri, "data:"), "token_uri() should be a json string");
}

#[test]
fn test_token_uri_hook() {
    let mut sys: TestSystems = setup_world(true, 0);
    tester::set_enable_uri_hooks(ref sys, true);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    println!("___token_uri_hook(1):[{}]", uri);
    assert_lt!(uri.len(), 100, "token_uri() len");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
    assert!(tester::starts_with(uri, "data:"), "token_uri() should be a json string");
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_token_uri_invalid() {
    let sys: TestSystems = setup_world(true, 0);
    sys.character.token_uri(TOKEN_ID_1);
}

//
// reserved supply
//

#[test]
fn test_reserved_ok() {
    let sys: TestSystems = setup_world(true, 0);
    // set reserved
    let max_supply: u256 = sys.character.max_supply();
    let reserved_supply: u256 = sys.character.reserved_supply();
    assert_eq!(max_supply, 10, "max_supply == 10");
    assert_eq!(reserved_supply, 0, "max_supply == 0");
    assert_eq!(sys.character.available_supply(), 10, "available_supply: 10");
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(8);
    let mut reserved_supply: u256 = sys.character.reserved_supply();
    assert_eq!(reserved_supply, 8, "reserved_supply == 8");
    assert_eq!(sys.character.available_supply(), 2, "available_supply: 2");
    assert_eq!(sys.character.total_supply(), 0, "total_supply: 0");
    // mint available first
    _mint(sys, OWNER());
    _mint(sys, OWNER());
    assert_eq!(sys.character.total_supply(), 2, "total_supply: 2");
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    assert!(!sys.character.is_minted_out(), "!is_minted_out");
    // mint reserved last
    while (sys.character.last_token_id() < max_supply) {
        _mint_reserved(sys, OWNER());
        reserved_supply -= 1;
        assert_eq!(sys.character.reserved_supply(), reserved_supply, "reserved_supply == {}", reserved_supply);
    };
    assert_eq!(sys.character.total_supply(), max_supply, "total_supply: full");
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    assert_eq!(sys.character.reserved_supply(), 0, "reserved_supply: 0");
    assert!(sys.character.is_minted_out(), "is_minted_out");
}

#[test]
fn test_reserved_first_ok() {
    let sys: TestSystems = setup_world(true, 0);
    assert_eq!(sys.character.available_supply(), 10, "available_supply: 10");
    // set reserved
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(8);
    assert_eq!(sys.character.reserved_supply(), 8, "reserved_supply: 8");
    assert_eq!(sys.character.available_supply(), 2, "available_supply: 2");
    // mint reserved first
    let mut reserved_supply: u256 = sys.character.reserved_supply();
    while (sys.character.last_token_id() < 8) {
        _mint_reserved(sys, OWNER());
        reserved_supply -= 1;
        assert_eq!(sys.character.reserved_supply(), reserved_supply, "reserved_supply == {}", reserved_supply);
    };
    assert_eq!(sys.character.reserved_supply(), 0, "total_supply: 0");
    assert_eq!(sys.character.total_supply(), 8, "total_supply: full");
    assert_eq!(sys.character.available_supply(), 2, "available_supply: 2");
    assert!(!sys.character.is_minted_out(), "!is_minted_out");
    // mint available last
    _mint(sys, OWNER());
    _mint(sys, OWNER());
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    assert_eq!(sys.character.total_supply(), 10, "total_supply: full");
    assert!(sys.character.is_minted_out(), "is_minted_out");
}

#[test]
fn test_reserved_mixed_ok() {
    let sys: TestSystems = setup_world(true, 0);
    // set reserved
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(5);
    let mut reserved_supply: u256 = sys.character.reserved_supply();
    // mint one of each
    while (reserved_supply > 0) {
        _mint(sys, OWNER());
        _mint_reserved(sys, OWNER());
        reserved_supply -= 1;
        assert_eq!(sys.character.reserved_supply(), reserved_supply, "reserved_supply == {}", reserved_supply);
    };
    assert_eq!(sys.character.reserved_supply(), 0, "reserved_supply: 0");
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
}

#[test]
#[should_panic(expected:('ERC721Combo: reserved supply', 'ENTRYPOINT_FAILED'))]
fn test_reserved_reserved() {
    let sys: TestSystems = setup_world(true, 0);
    // same as test_reserved_ok()
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(8);
    assert_eq!(sys.character.available_supply(), 2, "available_supply: 2");
    // mint available
    _mint(sys, OWNER());
    _mint(sys, OWNER());
    // panic!
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    _mint(sys, OWNER());
}

#[test]
#[should_panic(expected:('ERC721Combo: no reserve', 'ENTRYPOINT_FAILED'))]
fn test_reserved_no_reserve() {
    let sys: TestSystems = setup_world(true, 0);
    // same as test_reserved_ok()
    tester::impersonate(OWNER());
    _mint_reserved(sys, OWNER());
}

#[test]
#[should_panic(expected:('ERC721Combo: invalid supply', 'ENTRYPOINT_FAILED'))]
fn test_reserved_invalid_supply_more_than_max() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(11);
}

#[test]
#[should_panic(expected:('ERC721Combo: invalid supply', 'ENTRYPOINT_FAILED'))]
fn test_reserved_invalid_supply_more_than_available() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    _mint(sys, OWNER());
    _mint(sys, OWNER());
    assert_eq!(sys.character.available_supply(), 8, "available_supply: 8");
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(9);
}

#[test]
#[should_panic(expected:('ERC721Combo: invalid supply', 'ENTRYPOINT_FAILED'))]
fn test_reserved_invalid_supply_minted_out() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    sys.character.update_max_supply(Option::Some(2));
    _mint(sys, OWNER());
    _mint(sys, OWNER());
    assert_eq!(sys.character.available_supply(), 0, "available_supply: 0");
    tester::impersonate(OWNER());
    sys.character.update_reserved_supply(1);
}

#[test]
#[should_panic(expected:('CHARACTER: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_set_reserved_supply_not_owner() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OTHER());
    sys.character.update_reserved_supply(50);
}






//
// contract_uri
//

#[test]
fn test_contract_uri_default() {
    let mut sys: TestSystems = setup_world(true, 0);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("___contract_uri_default(1):[{}]", uri);
    assert_ne!(uri, "", "contract_uri() should not be empty");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    assert!(tester::starts_with(uri, "https:"), "contract_uri() should start with https:");
}

#[test]
fn test_contract_uri_default_none() {
    let mut sys: TestSystems = setup_world(true, 0);
    sys.character.update_contract_uri(Option::None);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("___contract_uri_automatic(1):[{}]", uri);
    assert_ne!(uri, "", "contract_uri() should not be empty");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
}

#[test]
fn test_contract_uri_render_hook() {
    let mut sys: TestSystems = setup_world(true, 0);
    tester::set_enable_uri_render_hooks(ref sys, true);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("___contract_uri_render(1):[{}]", uri);
    assert_gt!(uri.len(), 100, "contract_uri() len");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
}

#[test]
fn test_contract_uri_hook() {
    let mut sys: TestSystems = setup_world(true, 0);
    tester::set_enable_uri_hooks(ref sys, true);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("___contract_uri_hook(1):[{}]", uri);
    assert_lt!(uri.len(), 100, "contract_uri() len");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
}

#[test]
fn test_contract_uri_updated() {
    let sys: TestSystems = setup_world(true, 0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.update_contract();
    let _event = tester::pop_log::<combo::ContractURIUpdated>(sys.character.contract_address, selector!("ContractURIUpdated")).unwrap();
}


//
// metadata_update
//

#[test]
fn test_metadata_update() {
    let sys: TestSystems = setup_world(true, 0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.update_character(TOKEN_ID_3);
    let event = tester::pop_log::<combo::MetadataUpdate>(sys.character.contract_address, selector!("MetadataUpdate")).unwrap();
    assert_eq!(event.token_id, TOKEN_ID_3, "event.token_id");
}

#[test]
fn test_batch_metadata_update() {
    let sys: TestSystems = setup_world(true, 0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.update_characters(TOKEN_ID_2, TOKEN_ID_4);
    let event = tester::pop_log::<combo::BatchMetadataUpdate>(sys.character.contract_address, selector!("BatchMetadataUpdate")).unwrap();
    assert_eq!(event.from_token_id, TOKEN_ID_2, "event.from_token_id");
    assert_eq!(event.to_token_id, TOKEN_ID_4, "event.to_token_id");
}



//
// royalty_info
//

#[test]
fn test_default_royalty() {
    let sys: TestSystems = setup_world(true, 0);
    let (receiver, numerator, denominator) = sys.character.default_royalty();
    assert!(receiver.is_non_zero(), "default: receiver is zero");
    assert_ne!(numerator, 0, "default: numerator is zero");
    assert_ne!(denominator, 0, "default: denominator is zero");
    assert_eq!(receiver, character::TREASURY(), "default: wrong receiver");
    assert_eq!(numerator, 500, "default: wrong numerator");
    // set
    sys.character.set_royalty(RECEIVER(), 400);
    let (receiver, numerator, denominator) = sys.character.default_royalty();
    assert_eq!(receiver, RECEIVER(), "set: wrong receiver");
    assert_eq!(numerator, 400, "set: wrong numerator");
    assert_ne!(denominator, 0, "set: denominator is zero");
    // reset
    sys.character.reset_royalty();
    let (receiver, numerator, denominator) = sys.character.default_royalty();
    assert!(receiver.is_zero(), "reset: receiver is not zero");
    assert_eq!(numerator, 0, "reset: numerator is not zero");
    assert_ne!(denominator, 0, "reset: denominator is zero");
}

#[test]
#[should_panic(expected:('CHARACTER: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_set_royalty_not_owner() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OTHER());
    sys.character.set_royalty(OTHER(), 1000);
}

#[test]
#[should_panic(expected:('CHARACTER: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_reset_royalty_not_owner() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OTHER());
    sys.character.reset_royalty();
}

#[test]
fn test_royalty_info() {
    let mut sys: TestSystems = setup_world(true, 0);
    // _mint(sys, OWNER()); // no need to mint
    // test defautl royalty
    let PRICE: u256 = WEI(100); // 100 ETH
    let (receiver, fees) = sys.character.royalty_info(1, PRICE);
    assert_eq!(receiver, character::TREASURY(), "default: wrong receiver");
    assert_eq!(fees, WEI(5), "default: wrong fees"); // default 5%
    // use default_royalty() hook -- precedence over default
    tester::set_enable_default_royalty_hook(ref sys, true);
    let (receiver, fees) = sys.character.royalty_info(1, PRICE);
    assert_eq!(receiver, character::RECEIVER_DEFAULT(), "default_hook: wrong receiver");
    assert_eq!(fees, WEI(3), "default_hook: wrong fees"); // default 5%
    // use token_royalty() hook -- precedence over all
    tester::set_enable_token_royalty_hook(ref sys, true);
    let (receiver, fees) = sys.character.royalty_info(1, PRICE);
    assert_eq!(receiver, character::RECEIVER_TOKEN(), "token_hook: wrong receiver");
    assert_eq!(fees, WEI(1), "token_hook: wrong fees"); // default 5%
}

#[test]
fn test_token_royalty() {
    let mut sys: TestSystems = setup_world(true, 0);
    // _mint(sys, OWNER()); // no need to mint
    // test defautl royalty
    let (receiver, numerator, denominator) = sys.character.token_royalty(1);
    assert_eq!(receiver, character::TREASURY(), "default: wrong receiver");
    assert_eq!(numerator, 500, "default: wrong numerator");
    assert_ne!(denominator, 0, "default: denominator is zero");
    // use default_royalty() hook -- precedence over default
    tester::set_enable_default_royalty_hook(ref sys, true);
    let (receiver, numerator, denominator) = sys.character.token_royalty(1);
    assert_eq!(receiver, character::RECEIVER_DEFAULT(), "default_hook: wrong receiver");
    assert_eq!(numerator, character::FEES_DEFAULT(), "default_hook: wrong numerator");
    assert_ne!(denominator, 0, "default_hook: denominator is zero");
    // use token_royalty() hook -- precedence over all
    tester::set_enable_token_royalty_hook(ref sys, true);
    let (receiver, numerator, denominator) = sys.character.token_royalty(1);
    assert_eq!(receiver, character::RECEIVER_TOKEN(), "token_hook: wrong receiver");
    assert_eq!(numerator, character::FEES_TOKEN(), "token_hook: wrong numerator");
    assert_ne!(denominator, 0, "token_hook: denominator is zero");
}
