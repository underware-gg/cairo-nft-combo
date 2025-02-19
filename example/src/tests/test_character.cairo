use starknet::{ContractAddress};
use openzeppelin_token::erc721::interface as erc721_interface;
use nft_combo::erc721::erc721_combo::{ERC721ComboComponent as combo};
use nft_combo::erc721::interface as combo_interface;
use example::tests::tester::{
    tester,
    tester::{
        setup_world, TestSystems,
        // IActionsDispatcherTrait,
        ICharacterDispatcherTrait,
        // ICashDispatcherTrait,
        OWNER, OTHER,
    }
};

const TOKEN_ID_1: u256 = 1;
const TOKEN_ID_2: u256 = 2;
const TOKEN_ID_3: u256 = 3;
const TOKEN_ID_4: u256 = 4;

fn _mint(mut sys: TestSystems, recipient: ContractAddress   ) {
    tester::impersonate(sys.actions.contract_address);
    sys.character.mint(recipient);
}

#[test]
fn test_initializer() {
    let sys: TestSystems = setup_world(0);
    println!("--- character SYMBOL:[{}] NAME:[{}]", sys.character.symbol(), sys.character.name());
    assert_eq!(sys.character.symbol(), "CHARACTER", "Symbol is wrong");
    assert_ne!(sys.character.name(), "", "Name is wrong");
    assert!(sys.character.supports_interface(erc721_interface::IERC721_ID), "should support IERC721_ID");
    assert!(sys.character.supports_interface(erc721_interface::IERC721_METADATA_ID), "should support METADATA");
    assert!(sys.character.supports_interface(combo_interface::IERC7572_ID), "should support IERC7572_ID");
    assert!(sys.character.supports_interface(combo_interface::IERC4906_ID), "should support IERC4906_ID");
}

//
// token_component
//

#[test]
fn test_token_mint_count() {
    let sys: TestSystems = setup_world(0);
    assert_eq!(sys.character.minted_count(), 0, "minted_count == 0");
    _mint(sys, OWNER());
    assert_eq!(sys.character.minted_count(), 1, "minted_count == 1");
    _mint(sys, OTHER());
    _mint(sys, OTHER());
    assert_eq!(sys.character.minted_count(), 3, "minted_count == 3");
}

#[test]
fn test_token_can_mint() {
    let sys: TestSystems = setup_world(0);
    assert!(!sys.character.can_mint(OWNER()), "can_mint(OWNER)");
    assert!(sys.character.can_mint(sys.actions.contract_address), "can_mint(actions)");
}

#[test]
fn test_token_exists() {
    let sys: TestSystems = setup_world(0);
    assert!(!sys.character.exists(TOKEN_ID_1.low), "exists false");
    _mint(sys, OWNER());
    assert!(sys.character.exists(TOKEN_ID_1.low), "exists true");
}

#[test]
fn test_token_is_owner_of() {
    let sys: TestSystems = setup_world(0);
    _mint(sys, OWNER());
    _mint(sys, OTHER());
    assert!(sys.character.is_owner_of(OWNER(), TOKEN_ID_1.low), "is_owner_of(OWNER, TOKEN_ID_1)");
    assert!(!sys.character.is_owner_of(OTHER(), TOKEN_ID_1.low), "is_owner_of(OTHER, TOKEN_ID_1)");
    assert!(!sys.character.is_owner_of(OWNER(), TOKEN_ID_2.low), "is_owner_of(OWNER, TOKEN_ID_2)");
    assert!(sys.character.is_owner_of(OTHER(), TOKEN_ID_2.low), "is_owner_of(OTHER, TOKEN_ID_2)");
}


//
// mint / burn / supply
//

#[test]
fn test_mint_burn_supply() {
    let sys: TestSystems = setup_world(0);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) : 0");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) : 0");
    assert_eq!(sys.character.total_supply(), 0, "total_supply : 0");
    assert_eq!(sys.character.last_token_id(), 0, "last_token_id : 0");
    // mint TOKEN_ID_1
    _mint(sys, OWNER());
    assert_eq!(sys.character.owner_of(TOKEN_ID_1), OWNER(), "owner_of_1");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) +1");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) +0");
    assert_eq!(sys.character.total_supply(), 1, "total_supply +1");
    assert_eq!(sys.character.last_token_id(), 1, "last_token_id +1");
    // validate CamelOnly
    assert_eq!(sys.character.totalSupply(), 1, "totalSupply +1");
    assert_eq!(sys.character.lastTokenId(), 1, "lastTokenId +1");
    // mint TOKEN_ID_2
    _mint(sys, OTHER());
    assert_eq!(sys.character.owner_of(TOKEN_ID_2), OTHER(), "owner_of_2");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) =1");
    assert_eq!(sys.character.balance_of(OTHER()), 1, "balance_of (OTHER) +1");
    assert_eq!(sys.character.total_supply(), 2, "total_supply +2");
    assert_eq!(sys.character.last_token_id(), 2, "last_token_id +2");
    // mint TOKEN_ID_3
    _mint(sys, OTHER());
    assert_eq!(sys.character.owner_of(TOKEN_ID_3), OTHER(), "owner_of_3");
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER) ==1");
    assert_eq!(sys.character.balance_of(OTHER()), 2, "balance_of (OTHER) +2");
    assert_eq!(sys.character.total_supply(), 3, "total_supply +3");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id +3");
    // mint TOKEN_ID_1
    tester::impersonate(OWNER());
    sys.character.burn(TOKEN_ID_1.low);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) -1=0");
    assert_eq!(sys.character.balance_of(OTHER()), 2, "balance_of (OTHER) +1=2");
    assert_eq!(sys.character.total_supply(), 2, "total_supply -1=2");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id =3");
    // mint TOKEN_ID_2, TOKEN_ID_3
    tester::impersonate(OTHER());
    sys.character.burn(TOKEN_ID_2.low);
    sys.character.burn(TOKEN_ID_3.low);
    assert_eq!(sys.character.balance_of(OWNER()), 0, "balance_of (OWNER) << 0");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) << 0");
    assert_eq!(sys.character.total_supply(), 0, "total_supply << 0");
    assert_eq!(sys.character.last_token_id(), 3, "last_token_id ==3");
}

#[test]
#[should_panic(expected:('TOKEN: caller is not minter', 'ENTRYPOINT_FAILED'))]
fn test_mint_not_minter() {
    let sys: TestSystems = setup_world(0);
    tester::impersonate(OWNER());
    sys.character.mint(OWNER());
}

#[test]
#[should_panic(expected:('TOKEN: caller is not owner', 'ENTRYPOINT_FAILED'))]
fn test_burn_not_owner() {
    let sys: TestSystems = setup_world(0);
    _mint(sys, OWNER());
    tester::impersonate(OTHER());
    sys.character.burn(TOKEN_ID_1.low);
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_not_minted() {
    let sys: TestSystems = setup_world(0);
    sys.character.owner_of(TOKEN_ID_1);
}

//
// token_uri
//

#[test]
fn test_token_uri_default() {
    let mut sys: TestSystems = setup_world(0);
    tester::set_skip_uri_hooks(ref sys, true);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    println!("--- token_uri(1): {}", uri);
    assert_ne!(uri, "", "token_uri() should not be empty");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
    let first_char: felt252 = uri[0].into();
    assert_eq!(first_char, 'h', "token_uri() should start with http");
}

#[test]
fn test_token_uri() {
    let sys: TestSystems = setup_world(0);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    println!("--- token_uri(1): {}", uri);
    assert_ne!(uri, "", "token_uri() should not be empty");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
    let first_char: felt252 = uri[0].into();
    assert_eq!(first_char, '{', "token_uri() should be a json string");
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_token_uri_invalid() {
    let sys: TestSystems = setup_world(0);
    sys.character.token_uri(TOKEN_ID_1);
}

//
// contract_uri
//

#[test]
fn test_contract_uri_default() {
    let mut sys: TestSystems = setup_world(0);
    tester::set_skip_uri_hooks(ref sys, true);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("--- contract_uri(1): {}", uri);
    assert_ne!(uri, "", "contract_uri() should not be empty");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    let first_char: felt252 = uri[0].into();
    assert_eq!(first_char, 'h', "contract_uri() should start with http");
}

#[test]
fn test_contract_uri() {
    let sys: TestSystems = setup_world(0);
    let uri: ByteArray = sys.character.contract_uri();
    let uri_camel = sys.character.contractURI();
    println!("--- contract_uri(1): {}", uri);
    assert_ne!(uri, "", "contract_uri() should not be empty");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
    let first_char: felt252 = uri[0].into();
    assert_eq!(first_char, '{', "contract_uri() should be a json string");
}

#[test]
fn test_contract_uri_updated() {
    let sys: TestSystems = setup_world(0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.emit_contract_uri_updated();
    let _event = tester::pop_log::<combo::ContractURIUpdated>(sys.character.contract_address, selector!("ContractURIUpdated")).unwrap();
}


//
// metadata_update
//

#[test]
fn test_metadata_update() {
    let sys: TestSystems = setup_world(0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.emit_metadata_update(TOKEN_ID_3);
    let event = tester::pop_log::<combo::MetadataUpdate>(sys.character.contract_address, selector!("MetadataUpdate")).unwrap();
    assert_eq!(event.token_id, TOKEN_ID_3, "event.token_id");
}

#[test]
fn test_batch_metadata_update() {
    let sys: TestSystems = setup_world(0);
    tester::drop_all_events(sys.character.contract_address);
    sys.character.emit_batch_metadata_update(TOKEN_ID_2, TOKEN_ID_4);
    let event = tester::pop_log::<combo::BatchMetadataUpdate>(sys.character.contract_address, selector!("BatchMetadataUpdate")).unwrap();
    assert_eq!(event.from_token_id, TOKEN_ID_2, "event.from_token_id");
    assert_eq!(event.to_token_id, TOKEN_ID_4, "event.to_token_id");
}

