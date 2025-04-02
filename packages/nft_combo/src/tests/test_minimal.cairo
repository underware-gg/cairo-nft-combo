// use core::num::traits::Zero;
use starknet::{ContractAddress, testing};
use openzeppelin_introspection::{interface as src5_interface};
use openzeppelin_token::erc721::{interface as erc721_interface};
use crate::common::{interface as common_interface};
use crate::erc721::erc721_combo::{ERC721ComboComponent};
use crate::erc721::erc721_combo::ERC721ComboComponent::{ERC721ComboMixinImpl, InternalImpl};
use crate::tests::mock_minimal_erc721::{MinimalERC721Mock, IMinimalERC721Mock};

pub fn TOKEN_NAME()     -> ByteArray {("Minimal")}
pub fn TOKEN_SYMBOL()   -> ByteArray {("MINI")}
pub fn BASE_URI()       -> ByteArray {("https://api.minimal.contract/token/")}

pub fn OWNER() -> ContractAddress { starknet::contract_address_const::<0x111>() }
pub fn OTHER() -> ContractAddress { starknet::contract_address_const::<0x222>() }

const TOKEN_ID_1: u256 = 1;
const TOKEN_ID_2: u256 = 2;
const TOKEN_ID_3: u256 = 3;

//
// Setup testing states
//
type ComponentState = ERC721ComboComponent::ComponentState<MinimalERC721Mock::ContractState>;
fn CONTRACT_STATE() -> MinimalERC721Mock::ContractState {
    MinimalERC721Mock::contract_state_for_testing()
}
fn COMPONENT_STATE() -> ComponentState {
    ERC721ComboComponent::component_state_for_testing()
}

fn setup() -> (ComponentState, MinimalERC721Mock::ContractState) {
    let mut state = COMPONENT_STATE();
    let mut mock_state = CONTRACT_STATE();
    state.initializer(
        TOKEN_NAME(),
        TOKEN_SYMBOL(),
        BASE_URI(),
        Option::None, // generate default contract_uri
        Option::None, // infinite supply
    );
    (state, mock_state)
}

pub fn impersonate(address: ContractAddress) {
    testing::set_contract_address(address);
    testing::set_account_contract_address(address);
}

//
// Initializer
//

#[test]
fn test_initializer() {
    let (mut _state, mut mock_state) = setup();
    println!("___minimal SYMBOL:[{}] NAME:[{}]", mock_state.symbol(), mock_state.name());
    assert_eq!(mock_state.symbol(), TOKEN_SYMBOL(), "Symbol is wrong");
    assert_eq!(mock_state.name(), TOKEN_NAME(), "Name is wrong");
    assert!(mock_state.supports_interface(src5_interface::ISRC5_ID), "should support ISRC5_ID");
    assert!(mock_state.supports_interface(erc721_interface::IERC721_ID), "should support IERC721_ID");
    assert!(mock_state.supports_interface(erc721_interface::IERC721_METADATA_ID), "should support METADATA");
    assert!(mock_state.supports_interface(common_interface::IERC7572_ID), "should support IERC7572_ID");
    assert!(mock_state.supports_interface(common_interface::IERC4906_ID), "should support IERC4906_ID");
    assert!(mock_state.supports_interface(common_interface::IERC2981_ID), "should support IERC2981_ID");
}

//
// mint / burn / supply
//

fn _mint(ref mock_state: MinimalERC721Mock::ContractState, recipient: ContractAddress   ) {
    impersonate(recipient);
    mock_state.mint(recipient);
}

#[test]
fn test_mint_supply() {
    let (mut _state, mut mock_state) = setup();
    assert_eq!(mock_state.balance_of(OWNER()), 0, "balance_of (OWNER) : 0");
    assert_eq!(mock_state.balance_of(OTHER()), 0, "balance_of (OTHER) : 0");
    assert_eq!(mock_state.total_supply(), 0, "total_supply : 0");
    assert_eq!(mock_state.last_token_id(), 0, "last_token_id : 0");
    assert!(!mock_state.token_exists(TOKEN_ID_1), "!exists(TOKEN_ID_1)");
    // mint TOKEN_ID_1
    _mint(ref mock_state, OWNER());
    assert!(mock_state.token_exists(TOKEN_ID_1), "exists(TOKEN_ID_1)");
    assert!(mock_state.is_owner_of(OWNER(), TOKEN_ID_1), "is_owner_of(OWNER(), TOKEN_ID_1)");
    assert!(!mock_state.is_owner_of(OTHER(), TOKEN_ID_1), "!is_owner_of(OTHER(), TOKEN_ID_1)");
    assert_eq!(mock_state.owner_of(TOKEN_ID_1), OWNER(), "owner_of_1");
    assert_eq!(mock_state.balance_of(OWNER()), 1, "balance_of (OWNER) +1");
    assert_eq!(mock_state.balance_of(OTHER()), 0, "balance_of (OTHER) +0");
    assert_eq!(mock_state.total_supply(), 1, "total_supply +1");
    assert_eq!(mock_state.last_token_id(), 1, "last_token_id +1");
    assert_eq!(mock_state.totalSupply(), 1, "totalSupply +1");
}

#[test]
fn test_token_uri() {
    let (mut _state, mut mock_state) = setup();
    _mint(ref mock_state, OWNER());
    let uri: ByteArray = mock_state.token_uri(TOKEN_ID_1);
    let uri_camel = mock_state.tokenURI(TOKEN_ID_1);
    println!("___token_uri(1):[{}]", uri);
    assert_ne!(uri, "", "token_uri() should not be empty");
    assert_eq!(uri, uri_camel, "tokenURI() == token_uri()");
}

#[test]
fn test_contract_uri_default() {
    let (mut _state, mut mock_state) = setup();
    let uri: ByteArray = mock_state.contract_uri();
    let uri_camel = mock_state.contractURI();
    println!("___contract_uri(1):[{}]", uri);
    assert_ne!(uri, "", "contract_uri() should not be empty");
    assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
}
