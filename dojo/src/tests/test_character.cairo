use debug::PrintTrait;
use starknet::{ContractAddress, get_contract_address, get_caller_address, testing};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::model::{Model, ModelTest, ModelIndex, ModelEntityTest};
use dojo::utils::test::spawn_test_world;

use oz_token::tests::{
    utils,
    utils::{OWNER, RECIPIENT, SPENDER, ZERO},
};
use oz_token::systems::character::{
    character, ICharacterDispatcher, ICharacterDispatcherTrait,
};
use oz_token::models::token_config::{TokenConfig};

use openzeppelin_token::erc721::interface;
use openzeppelin_token::erc721::{
    ERC721Component,
    ERC721Component::{
        Transfer, Approval,
    }
};

//
// events helpers
//

fn assert_event_transfer(
    emitter: ContractAddress, from: ContractAddress, to: ContractAddress, token_id: u256
) {
    let event = utils::pop_log::<Transfer>(emitter).unwrap();
    assert(event.from == from, 'Invalid `from`');
    assert(event.to == to, 'Invalid `to`');
    assert(event.token_id == token_id, 'Invalid `token_id`');
}

fn assert_only_event_transfer(
    emitter: ContractAddress, from: ContractAddress, to: ContractAddress, token_id: u256
) {
    assert_event_transfer(emitter, from, to, token_id);
    utils::assert_no_events_left(emitter);
}

fn assert_event_approval(
    emitter: ContractAddress, owner: ContractAddress, approved: ContractAddress, token_id: u256
) {
    // let expected = ERC721Component::Event::Approval(Approval { owner, approved, token_id });
    let event = utils::pop_log::<Approval>(emitter).unwrap();
// 'params'.print();
// emitter.print();
// owner.print();
// approved.print();
// token_id.print();
// 'event'.print();
// event.owner.print();
// event.approved.print();
// event.token_id.print();
// '-----'.print();
    assert(event.owner == owner, 'Invalid `owner`');
    assert(event.approved == approved, 'Invalid `approved`');
    assert(event.token_id == token_id, 'Invalid `token_id`');
}

fn assert_only_event_approval(
    emitter: ContractAddress, owner: ContractAddress, approved: ContractAddress, token_id: u256
) {
    assert_event_approval(emitter, owner, approved, token_id);
    utils::assert_no_events_left(emitter);
}


//
// Setup
//

const TOKEN_ID_1: u256 = 1;
const TOKEN_ID_2: u256 = 2;
const TOKEN_ID_3: u256 = 3;
const TOKEN_ID_4: u256 = 4;
const TOKEN_ID_5: u256 = 5;

fn setup_uninitialized() -> (IWorldDispatcher, ICharacterDispatcher) {
    testing::set_block_number(1);
    testing::set_block_timestamp(1);
    let mut world = spawn_test_world(
        ["oz_token"].span(),
        get_models_test_class_hashes!(),
    );

    let mut token = ICharacterDispatcher {
        contract_address: world.deploy_contract('salt', character::TEST_CLASS_HASH.try_into().unwrap())
    };
    world.grant_owner(dojo::utils::bytearray_hash(@"oz_token"), token.contract_address);
    // world.grant_writer(selector_from_tag!("oz_token-TokenConfig"), token.contract_address);
    let duelists_call_data: Span<felt252> = array![].span();
    world.init_contract(selector_from_tag!("oz_token-character"), duelists_call_data);

    utils::impersonate(OWNER());

    (world, token)
}

fn setup() -> (IWorldDispatcher, ICharacterDispatcher) {
    let (mut world, mut token) = setup_uninitialized();

    // initialize contracts
    _mint(token, OWNER());
    _mint(token, RECIPIENT());

    // drop all events
    utils::drop_all_events(world.contract_address);
    utils::drop_all_events(token.contract_address);

    (world, token)
}

fn _mint(token: ICharacterDispatcher, recipient: ContractAddress) {
    token.mint(recipient);
}

fn _assert_minted_count(world: IWorldDispatcher, token: ICharacterDispatcher, minted_count: u128) {
    let token_config: TokenConfig = get!(world, token.contract_address, TokenConfig);
    assert(token_config.minted_count == minted_count, 'token_config.minted_count');
}

//
// initialize
//

#[test]
fn test_initializer() {
    let (world, mut token) = setup();

    println!("NAME: [{}]", token.name());
    println!("SYMBOL: [{}]", token.symbol());
    // assert(token.name() == "Sample Character", 'Name is wrong');
    assert(token.symbol() == "CHARACTER", 'Symbol is wrong');

    // assert(token.total_supply() == 2, 'Should eq 2');
    // assert(token.balance_of(OWNER(),) == 1, 'Should eq 1 (OWNER)');
    // assert(token.balance_of(RECIPIENT()) == 1, 'Should eq 1 (RECIPIENT)');

    // assert(token.token_of_owner_by_index(OWNER(), 0) == TOKEN_ID_1, 'token_of_owner_by_index_OWNER');
    // assert(token.token_of_owner_by_index(RECIPIENT(), 0) == TOKEN_ID_2, 'token_of_owner_by_index_REC');

    // assert(token.token_by_index(0) == TOKEN_ID_1, 'token_by_index_0');
    // assert(token.token_by_index(1) == TOKEN_ID_2, 'token_by_index_1');

    assert(token.owner_of(TOKEN_ID_1) == OWNER(), 'owner_of_1');
    assert(token.owner_of(TOKEN_ID_2) == RECIPIENT(), 'owner_of_2');

    assert(token.owner_of(TOKEN_ID_1).is_non_zero(), 'owner_of_1_non_zero');
    assert(token.owner_of(TOKEN_ID_2).is_non_zero(), 'owner_of_2_non_zero');

    assert(token.token_uri(TOKEN_ID_1) != "", 'Uri should not be empty');
    assert(token.tokenURI(TOKEN_ID_1) != "", 'Uri should not be empty Camel');

    assert(token.supports_interface(interface::IERC721_ID) == true, 'should support IERC721_ID');
    assert(token.supports_interface(interface::IERC721_METADATA_ID) == true, 'should support METADATA');
    // assert(token.supports_interface(interface::IERC721_ENUMERABLE_ID) == true, 'should support ENUMERABLE');

    _assert_minted_count(world, token, 2);
}

#[test]
fn test_token_uri() {
    let (mut _world, mut token) = setup();

    let uri_1 = token.token_uri(TOKEN_ID_1);
    // let uri_2 = token.token_uri(TOKEN_ID_2);
    
    println!("token_uri(1): {}", uri_1);
    // println!("token_uri(2): {}", uri_2);

    assert(uri_1[0] == '{', 'Uri 1 should not be empty');
    // assert(uri_2[0] == '{', 'Uri 2 should not be empty');
}

#[test]
#[should_panic(expected: ('ERC721: invalid token ID', 'ENTRYPOINT_FAILED'))]
fn test_token_uri_invalid() {
    let (_world, mut token) = setup();
    token.token_uri(999);
}


//
// approve
//

#[test]
fn test_approve() {
    let (world, mut token) = setup();

    utils::impersonate(OWNER(),);

    token.approve(SPENDER(), TOKEN_ID_1);
    assert(token.get_approved(TOKEN_ID_1) == SPENDER(), 'Spender not approved correctly');

    // drop StoreSetRecord ERC721TokenApprovalModel
    utils::drop_event(world.contract_address);

    assert_only_event_approval(token.contract_address, OWNER(), SPENDER(), TOKEN_ID_1);
}

//
// transfer_from
//

#[test]
fn test_transfer_from() {
    let (world, mut token) = setup();

    utils::impersonate(OWNER(),);
    token.approve(SPENDER(), TOKEN_ID_1);

    utils::drop_all_events(token.contract_address);
    utils::drop_all_events(world.contract_address);
    utils::assert_no_events_left(token.contract_address);

    utils::impersonate(SPENDER());
    token.transfer_from(OWNER(), RECIPIENT(), TOKEN_ID_1);

    assert_only_event_transfer(token.contract_address, OWNER(), RECIPIENT(), TOKEN_ID_1);

    assert(token.balance_of(RECIPIENT()) == 2, 'Should eq 1');
    assert(token.balance_of(OWNER(),) == 0, 'Should eq 1');
    assert(token.get_approved(TOKEN_ID_1) == ZERO(), 'Should eq 0');
    // assert(token.total_supply() == 2, 'Should eq 2');
    // assert(token.token_of_owner_by_index(RECIPIENT(), 1) == TOKEN_ID_1, 'Should eq TOKEN_ID_1');
}

//
// mint
//

#[test]
fn test_mint_free() {
    let (world, mut token) = setup();
    // assert(token.total_supply() == 2, 'invalid total_supply init');
    assert(token.balance_of(RECIPIENT()) == 1, 'invalid balance_of');
    // assert(token.token_of_owner_by_index(RECIPIENT(), 0) == TOKEN_ID_2, 'token_of_owner_by_index_2');
    _mint(token, RECIPIENT());
    // assert(token.total_supply() == 3, 'invalid total_supply');
    assert(token.balance_of(RECIPIENT()) == 2, 'invalid balance_of');
    // assert(token.token_of_owner_by_index(RECIPIENT(), 1) == TOKEN_ID_3, 'token_of_owner_by_index_3');
    _assert_minted_count(world, token, 3);
}

#[test]
fn test_mint() {
    let (world, mut token) = setup();
    // assert(token.total_supply() == 2, 'invalid total_supply init');
    _mint(token, RECIPIENT());
    assert(token.balance_of(RECIPIENT()) == 2, 'invalid balance_of');
    // assert(token.total_supply() == 3, 'invalid total_supply');
    _assert_minted_count(world, token, 3);
}

// #[test]
// #[should_panic(expected: ('ERC721: no allowance', 'ENTRYPOINT_FAILED'))]
// fn test_mint_no_allowance() {
//     // TODO: this...
//     // let (_world, mut token) = setup();
//     // token.token_uri(999);
// }

//
// burn
//

// #[test]
// fn test_burn() {
//     let (_world, mut token) = setup();
//     assert(token.total_supply() == 2, 'invalid total_supply init');
//     assert(token.balance_of(OWNER()) == 1, 'invalid balance_of (1)');
//     token.delete_duelist(TOKEN_ID_1.low);
//     assert(token.total_supply() == 1, 'invalid total_supply');
//     assert(token.balance_of(OWNER()) == 0, 'invalid balance_of (0)');
// }

