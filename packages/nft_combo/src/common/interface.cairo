
use starknet::{ContractAddress};

// definitive IDs (OZ)
pub const IERC2981_ID: felt252 = 0x2d3414e45a8700c29f119a54b9f11dca0e29e06ddcb214018fc37340e165ed6;
// generated
// https://github.com/ericnordelo/src5-rs
// https://docs.openzeppelin.com/contracts-cairo/1.0.0/introspection#computing_the_interface_id
pub const IERC7572_ID: felt252 = 0x12c8405df0790491b695f1b5bf7d22c855ae0b1745deaa890f763bb9d0a06ca;
// TODO: theres no function to compute the id!!!
pub const IERC4906_ID: felt252 = selector!("IERC4906_ID");


//
// ERC-7572: Contract-level metadata
// https://eips.ethereum.org/EIPS/eip-7572
//
#[starknet::interface]
pub trait IERC7572ContractMetadata<TState> {
    // returns the contract metadata
    fn contract_uri(self: @TState) -> ByteArray;
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC7572ContractMetadataProtected<TState> {
    fn _set_contract_uri(ref self: TState, contract_uri: ByteArray);
    // returns the stored default value of contract_uri URI
    fn _contract_uri(self: @TState) -> ByteArray;
    // emits the `ContractURIUpdated` event
    fn _emit_contract_uri_updated(ref self: TState);
}

//
// ERC-4906: Metadata Update Extension
// https://eips.ethereum.org/EIPS/eip-4906
//
#[starknet::interface]
pub trait IERC4906MetadataUpdate<TState> {
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC4906MetadataUpdateProtected<TState> {
    // emits the `MetadataUpdate` event
    fn _emit_metadata_update(ref self: TState, token_id: u256);
    // emits the `BatchMetadataUpdate` event
    fn _emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
}

//
// ERC-2981: NFT Royalty Standard
// https://eips.ethereum.org/EIPS/eip-2981
//
#[starknet::interface]
pub trait IERC2981RoyaltyInfo<TState> {
    /// Returns how much royalty is owed and to whom, based on a sale price that may be denominated
    /// in any unit of exchange. The royalty amount is denominated and should be paid in that same
    /// unit of exchange.
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    /// Returns the royalty information that all ids in this contract will default to.
    /// The returned tuple contains:
    /// - `t.0`: The receiver of the royalty payment.
    /// - `t.1`: The numerator of the royalty fraction.
    /// - `t.2`: The denominator of the royalty fraction.
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    /// Returns the royalty information specific to a token.
    /// If no specific royalty information is set for the token, the default is returned.
    /// The returned tuple contains:
    /// - `t.0`: The receiver of the royalty payment.
    /// - `t.1`: The numerator of the royalty fraction.
    /// - `t.2`: The denominator of the royalty fraction.
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC2981RoyaltyInfoProtected<TState> {
    // Sets the royalty information that all ids in this contract will default to.
    // Requirements:
    // - `receiver` cannot be the zero address.
    // - `fee_numerator` cannot be greater than the fee denominator.
    fn _set_default_royalty(ref self: TState, receiver: ContractAddress, fee_numerator: u128);
    // Sets the default royalty percentage and receiver to zero.
    fn _delete_default_royalty(ref self: TState);
}
