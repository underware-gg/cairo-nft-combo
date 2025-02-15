use debug::PrintTrait;
use starknet::{ContractAddress, get_contract_address, get_caller_address, testing};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::model::{Model, ModelTest, ModelIndex, ModelEntityTest};
use dojo::utils::test::spawn_test_world;

use example::tests::{
    utils,
    utils::{OWNER, RECIPIENT, SPENDER, ZERO},
};
use example::systems::cash::{
    cash, ICashDispatcher, ICashDispatcherTrait,
};
use example::models::coin_config::{CoinConfig};

use openzeppelin_token::erc20::interface;
use openzeppelin_token::erc20::{
    ERC20Component,
    ERC20Component::{
        Transfer, Approval,
    }
};

//
// Setup
//

const ETH_TO_WEI: u256 = 1_000_000_000_000_000_000;
const FAUCET_AMOUNT: u256 = 1000;
const MINT_AMOUNT: u256 = 128;
const SPEND_AMOUNT: u256 = 111;

fn setup_uninitialized(faucet_amount: u256) -> (IWorldDispatcher, ICashDispatcher) {
    testing::set_block_number(1);
    testing::set_block_timestamp(1);
    let mut world = spawn_test_world(
        ["example"].span(),
        get_models_test_class_hashes!(),
    );

    let mut coin = ICashDispatcher {
        contract_address: world.deploy_contract('salt', cash::TEST_CLASS_HASH.try_into().unwrap())
    };
    world.grant_owner(dojo::utils::bytearray_hash(@"example"), coin.contract_address);
    // world.grant_writer(selector_from_tag!("example-CoinConfig"), coin.contract_address);
    let call_data: Span<felt252> = array![
        OWNER().into(),
        faucet_amount.low.into(),
        faucet_amount.high.into(),
    ].span();
    world.init_contract(selector_from_tag!("example-cash"), call_data);

    utils::impersonate(OWNER());

    (world, coin)
}

fn setup(faucet_amount: u256) -> (IWorldDispatcher, ICashDispatcher) {
    let (mut world, mut coin) = setup_uninitialized(faucet_amount);

    // initialize contracts
    coin.mint(OWNER(), MINT_AMOUNT);
    coin.mint(RECIPIENT(), MINT_AMOUNT);

    // drop all events
    utils::drop_all_events(world.contract_address);
    utils::drop_all_events(coin.contract_address);

    (world, coin)
}

//
// initialize
//

#[test]
fn test_initializer() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);

    println!("cash NAME:[{}] SYMBOL:[{}]", coin.symbol(), coin.name());
    // assert(coin.name() == "Sample Cash", 'Name is wrong');
    assert(coin.symbol() == "CA$H", 'Symbol is wrong');

    assert(coin.total_supply() == MINT_AMOUNT * 2, 'total_supply');
    assert(coin.balance_of(OWNER(),) == MINT_AMOUNT, 'balance_of (OWNER)');
    assert(coin.balance_of(RECIPIENT()) == MINT_AMOUNT, 'balance_of (RECIPIENT)');
    assert(coin.balance_of(SPENDER()) == 0, 'balance_of (SPENDER)');
}



//
// mint
//

#[test]
fn test_mint() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(OWNER());
    coin.mint(OWNER(), MINT_AMOUNT);
    coin.mint(RECIPIENT(), MINT_AMOUNT);
    assert(coin.total_supply() == MINT_AMOUNT * 4, 'total_supply');
    assert(coin.balance_of(OWNER(),) == MINT_AMOUNT * 2, 'balance_of (OWNER)');
    assert(coin.balance_of(RECIPIENT()) == MINT_AMOUNT * 2, 'balance_of (RECIPIENT)');
}

#[test]
#[should_panic(expected: ('COIN: caller is not minter', 'ENTRYPOINT_FAILED'))]
fn test_mint_not_minter() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(RECIPIENT());
    coin.mint(RECIPIENT(), MINT_AMOUNT);
}

#[test]
fn test_faucet() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(OWNER());
    coin.faucet(OWNER());
    coin.faucet(RECIPIENT());
    utils::impersonate(RECIPIENT());
    coin.faucet(OWNER());
    coin.faucet(RECIPIENT());
    assert(coin.total_supply() == MINT_AMOUNT * 2 + FAUCET_AMOUNT * 4, 'total_supply');
    assert(coin.balance_of(OWNER(),) == MINT_AMOUNT + FAUCET_AMOUNT * 2, 'balance_of (OWNER)');
    assert(coin.balance_of(RECIPIENT()) == MINT_AMOUNT + FAUCET_AMOUNT * 2, 'balance_of (RECIPIENT)');
}

#[test]
#[should_panic(expected: ('COIN: faucet unavailable', 'ENTRYPOINT_FAILED'))]
fn test_faucet_unavailable() {
    let (_world, mut coin) = setup(0);
    utils::impersonate(RECIPIENT());
    coin.faucet(RECIPIENT());
}



//
// approve / transfer
//

#[test]
fn test_approve() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(RECIPIENT());
    coin.approve(SPENDER(), SPEND_AMOUNT);
    assert(coin.allowance(RECIPIENT(), SPENDER()) == SPEND_AMOUNT, 'bad allowance');

    // utils::drop_event(world.contract_address);
    // assert_only_event_approval(coin.contract_address, OWNER(), SPENDER(), TOKEN_ID_1);

    utils::impersonate(SPENDER());
    coin.transfer_from(RECIPIENT(), SPENDER(), SPEND_AMOUNT);
    assert(coin.allowance(RECIPIENT(), SPENDER()) == 0, 'bad spent');
    assert(coin.balance_of(RECIPIENT()) == MINT_AMOUNT - SPEND_AMOUNT, 'balance_of (RECIPIENT)');
    assert(coin.balance_of(SPENDER()) == SPEND_AMOUNT, 'balance_of (SPENDER)');
}

#[test]
#[should_panic(expected: ('ERC20: insufficient allowance', 'ENTRYPOINT_FAILED'))]
fn test_approve_no_allowance() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(RECIPIENT());
    coin.transfer_from(RECIPIENT(), SPENDER(), SPEND_AMOUNT);
}

#[test]
fn test_transfer() {
    let (_world, mut coin) = setup(FAUCET_AMOUNT);
    utils::impersonate(RECIPIENT());
    coin.approve(SPENDER(), SPEND_AMOUNT);
    coin.transfer(SPENDER(), SPEND_AMOUNT);
    assert(coin.balance_of(RECIPIENT()) == MINT_AMOUNT - SPEND_AMOUNT, 'balance_of (RECIPIENT)');
    assert(coin.balance_of(SPENDER()) == SPEND_AMOUNT, 'balance_of (SPENDER)');
}
