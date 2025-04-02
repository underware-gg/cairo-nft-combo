// use starknet::{ContractAddress};
use crate::tests::tester::{
    tester,
    tester::{
        setup_world, TestSystems,
        // IActionsDispatcherTrait,
        // ICharacterDispatcherTrait,
        ICashDispatcherTrait,
        OWNER, RECIPIENT, SPENDER, ZERO,
        ETH_TO_WEI,
    }
};

const FAUCET_AMOUNT: u256 = 1000 * ETH_TO_WEI;
const SPEND_AMOUNT: u256 = 200 * ETH_TO_WEI;

#[test]
fn test_initializer() {
    let sys: TestSystems = setup_world(true, 0);
    println!("--- cash SYMBOL:[{}] NAME:[{}]", sys.cash.symbol(), sys.cash.name());
    assert_eq!(sys.cash.symbol(), "CA$H", "Symbol is wrong");
    assert_ne!(sys.cash.name(), "", "Name is wrong");
}

//
// mint
//

#[test]
#[should_panic(expected:('COIN: caller is not minter', 'ENTRYPOINT_FAILED'))]
fn test_mint_not_minter() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(RECIPIENT());
    sys.cash.mint(RECIPIENT(), FAUCET_AMOUNT);
}

#[test]
fn test_faucet() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    assert_eq!(sys.cash.total_supply(), 0, "total_supply_INTI");
    tester::impersonate(OWNER());
    sys.cash.faucet(OWNER());
    sys.cash.faucet(RECIPIENT());
    tester::impersonate(RECIPIENT());
    sys.cash.faucet(OWNER());
    sys.cash.faucet(RECIPIENT());
    assert_eq!(sys.cash.total_supply(), FAUCET_AMOUNT * 4, "total_supply_AFTER");
    assert_eq!(sys.cash.balance_of(OWNER()), FAUCET_AMOUNT * 2, "balance_of (OWNER)");
    assert_eq!(sys.cash.balance_of(RECIPIENT()), FAUCET_AMOUNT * 2, "balance_of (RECIPIENT)");
}

#[test]
#[should_panic(expected:('COIN: faucet unavailable', 'ENTRYPOINT_FAILED'))]
fn test_faucet_to_zero_address() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    sys.cash.faucet(ZERO());
}

#[test]
#[should_panic(expected:('COIN: faucet unavailable', 'ENTRYPOINT_FAILED'))]
fn test_faucet_unavailable() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    sys.cash.faucet(OWNER());
}

//
// approve / transfer
//

#[test]
fn test_transfer() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(OWNER());
    sys.cash.faucet(OWNER());
    assert_eq!(sys.cash.balance_of(OWNER()), FAUCET_AMOUNT, "balance_of (OWNER) == FAUCET_AMOUNT");
    sys.cash.transfer(RECIPIENT(), SPEND_AMOUNT);
    assert_eq!(sys.cash.balance_of(OWNER()), FAUCET_AMOUNT - SPEND_AMOUNT, "balance_of (OWNER)");
    assert_eq!(sys.cash.balance_of(RECIPIENT()), SPEND_AMOUNT, "balance_of (RECIPIENT)");
}

#[test]
#[should_panic(expected:('ERC20: insufficient balance', 'ENTRYPOINT_FAILED'))]
fn test_transfer_no_balance() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(OWNER());
    sys.cash.faucet(OWNER());
    sys.cash.transfer(RECIPIENT(), FAUCET_AMOUNT + SPEND_AMOUNT);
}

#[test]
fn test_approve_transfer_from() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(OWNER());
    sys.cash.faucet(OWNER());
    sys.cash.approve(SPENDER(), SPEND_AMOUNT);
    assert_eq!(sys.cash.allowance(OWNER(), SPENDER()), SPEND_AMOUNT, "bad allowance");

    // utils::drop_event(world.contract_address);
    // assert_only_event_approval(sys.cash.contract_address, OWNER(), SPENDER(), TOKEN_ID_1);

    tester::impersonate(SPENDER());
    sys.cash.transfer_from(OWNER(), RECIPIENT(), SPEND_AMOUNT);
    assert_eq!(sys.cash.allowance(OWNER(), SPENDER()), 0, "bad spent");
    assert_eq!(sys.cash.balance_of(OWNER()), FAUCET_AMOUNT - SPEND_AMOUNT, "balance_of (OWNER)");
    assert_eq!(sys.cash.balance_of(RECIPIENT()), SPEND_AMOUNT, "balance_of (RECIPIENT)");
}

#[test]
#[should_panic(expected:('ERC20: insufficient allowance', 'ENTRYPOINT_FAILED'))]
fn test_approve_no_allowance() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(SPENDER());
    sys.cash.transfer_from(OWNER(), RECIPIENT(), SPEND_AMOUNT);
}
