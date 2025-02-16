use starknet::{ContractAddress};
use openzeppelin_token::erc721::interface;
use example::models::token_config::{TokenConfig};
use example::libs::store::{StoreTrait};
// use example::libs::dns::{DnsTrait};
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

fn _assert_minted_count(mut sys: TestSystems, minted_count: u128, msg: ByteArray) {
    let token_config: TokenConfig = sys.store.get_token_config(sys.character.contract_address);
    assert_eq!(token_config.minted_count, minted_count, "{}", msg);
}

fn _mint(mut sys: TestSystems, recipient: ContractAddress   ) {
    tester::impersonate(sys.actions.contract_address);
    sys.character.mint(recipient);
}

#[test]
fn test_initializer() {
    let sys: TestSystems = setup_world(0);
    println!("character SYMBOL:[{}] NAME:[{}]", sys.character.symbol(), sys.character.name());
    assert_eq!(sys.character.symbol(), "CHARACTER", "Symbol is wrong");
    assert_ne!(sys.character.name(), "", "Name is wrong");
    assert!(sys.character.supports_interface(interface::IERC721_ID), "should support IERC721_ID");
    assert!(sys.character.supports_interface(interface::IERC721_METADATA_ID), "should support METADATA");
}

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
    _assert_minted_count(sys, 0, "minted_count == 0");
    assert_eq!(sys.character.balance_of(OTHER()), 0, "balance_of (OTHER) == 0");
    _mint(sys, OWNER());
    _mint(sys, OTHER());
    _mint(sys, OTHER());
    _assert_minted_count(sys, 3, "minted_count == 3");
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

#[test]
fn test_token_uri() {
    let sys: TestSystems = setup_world(0);
    _mint(sys, OWNER());
    let uri_1 = sys.character.token_uri(TOKEN_ID_1);
    assert_ne!(uri_1, "", "token_uri() should not be empty");
    assert_eq!(uri_1, sys.character.tokenURI(TOKEN_ID_1), "tokenURI() == token_uri()");
    println!("token_uri(1): {}", uri_1);
}

#[test]
#[should_panic(expected:('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_token_uri_invalid() {
    let sys: TestSystems = setup_world(0);
    sys.character.token_uri(TOKEN_ID_1);
}
