use starknet::{ContractAddress};
use openzeppelin_token::erc721::interface;
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
const TOKEN_ID_3: u256 = 2;
const TOKEN_ID_4: u256 = 2;

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
    assert!(sys.character.supports_interface(interface::IERC721_ID), "should support IERC721_ID");
    assert!(sys.character.supports_interface(interface::IERC721_METADATA_ID), "should support METADATA");
}

//
// mint
//

#[test]
#[should_panic(expected:('TOKEN: caller is not minter', 'ENTRYPOINT_FAILED'))]
fn test_mint_not_minter() {
    let sys: TestSystems = setup_world(0);
    tester::impersonate(OWNER());
    sys.character.mint(OWNER());
}

#[test]
fn test_mint() {
    let sys: TestSystems = setup_world(0);
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) == 0");
    _mint(sys, OWNER());
    _mint(sys, OTHER());
    _mint(sys, OTHER());
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER)");
    assert_eq!(sys.character.balance_of(OTHER()), 2, "balance_of (OTHER)");
    assert_eq!(sys.character.owner_of(TOKEN_ID_1), OWNER(), "owner_of_1");
    assert_eq!(sys.character.owner_of(TOKEN_ID_2), OTHER(), "owner_of_2");
    assert_eq!(sys.character.owner_of(TOKEN_ID_3), OTHER(), "owner_of_3");
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
fn test_token_uri() {
    let sys: TestSystems = setup_world(0);
    _mint(sys, OWNER());
    let uri: ByteArray = sys.character.token_uri(TOKEN_ID_1);
    println!("--- token_uri(1): {}", uri);
    assert_ne!(uri, "", "token_uri() should not be empty");
    let first_char: felt252 = uri[0].into();
    assert_eq!(first_char, '{', "token_uri() should be a json string");
    // camelCase must exist and return the same result
    let uri_camel = sys.character.tokenURI(TOKEN_ID_1);
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_token_uri_invalid() {
    let sys: TestSystems = setup_world(0);
    sys.character.token_uri(TOKEN_ID_1);
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

