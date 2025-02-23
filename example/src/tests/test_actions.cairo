// use starknet::{ContractAddress};
use example::tests::tester::{
    tester,
    tester::{
        setup_world, TestSystems,
        IActionsDispatcherTrait,
        ICharacterDispatcherTrait,
        ICashDispatcherTrait,
        OWNER,
        ETH_TO_WEI,
    }
};

const FAUCET_AMOUNT: u256 = 1000 * ETH_TO_WEI;

#[test]
fn test_cash_faucet() {
    let sys: TestSystems = setup_world(true, FAUCET_AMOUNT);
    tester::impersonate(OWNER());
    sys.actions.cash_faucet();
    assert_eq!(sys.cash.balance_of(OWNER()), FAUCET_AMOUNT, "balance_of (OWNER)");
}

#[test]
fn test_mint_character() {
    let sys: TestSystems = setup_world(true, 0);
    tester::impersonate(OWNER());
    sys.actions.mint_character();
    assert_eq!(sys.character.balance_of(OWNER()), 1, "balance_of (OWNER)");
    assert_eq!(sys.character.owner_of(1), OWNER(), "owner_of (OWNER)");
}
