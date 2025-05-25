pub trait IERC2981RoyaltyInfo {
    fn royalty_info(token_id: u256, sale_price: u256) -> (ContractAddress, u256);
}
